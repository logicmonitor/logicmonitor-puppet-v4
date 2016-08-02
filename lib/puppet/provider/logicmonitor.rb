# logicmonitor.rb
# Contains classes used by various providers in the LogicMonitor Puppet Module
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

require 'net/http'
require 'net/https'
require 'uri'
require 'openssl'
require 'base64'
require 'json'
require 'date'

class Puppet::Provider::Logicmonitor < Puppet::Provider

  HTTP_POST = 'POST'
  HTTP_GET = 'GET'
  HTTP_PUT = 'PUT'
  HTTP_PATCH = 'PATCH'
  HTTP_DELETE = 'DELETE'

  # Device API endpoints
  DEVICE_ENDPOINT = '/device/devices/%d'
  DEVICES_ENDPOINT = '/device/devices'
  DEVICE_PROPERTIES_ENDPOINT = '/device/devices/%d/properties'

  # Device Group API endpoints
  DEVICE_GROUP_ENDPOINT = '/device/groups/%d'
  DEVICE_GROUPS_ENDPOINT = '/device/groups'
  DEVICE_GROUP_PROPERTIES_ENDPOINT = '/device/groups/%d/properties'

  # Collector API endpoints
  COLLECTOR_ENDPOINT = '/setting/collectors/%d'
  COLLECTORS_ENDPOINT = '/setting/collectors'

  # Authentication Constants
  BASIC = 0
  TOKEN = 1

  # Execute a RESTful request to LogicMonitor
  # endpoint: RESTful endpoint to request
  # http_method: HTTP Method to use for RESTful request
  # query_params: Query Parameters to use in request (to modify results)
  # data: JSON data to send in HTTP POST RESTful requests
  # download_collector: If we are executing a download the URL will be santaba/do instead of santaba/rest
  def rest(connection, endpoint, http_method, query_params={}, data=nil, download_collector=false)
    # Sanity Check on Endpoint
    endpoint.prepend('/') unless endpoint.start_with?'/'

    # Build URI and add query Parameters
    if download_collector
      uri = URI.parse("https://#{resource[:account]}.logicmonitor.com/santaba/do/logicmonitorsetup")
    else
      uri = URI.parse("https://#{resource[:account]}.logicmonitor.com/santaba/rest#{endpoint}")
    end

    auth = check_auth

    if download_collector
      auth_query_params = {'c' => resource[:account], 'u' => resource[:user], 'p' => resource[:password]}
      if nil_or_empty?(query_params)
        query = auth_query_params
      else
        query = query_params.merge auth_query_params
      end
      uri.query = URI.encode_www_form query
    else
      uri.query = URI.encode_www_form query_params unless nil_or_empty?(query_params)
    end

    # Build Request Object
    request = nil
    if http_method.upcase == HTTP_POST
      raise ArgumentError, 'Invalid data for HTTP POST request' if nil_or_empty? data
      request = Net::HTTP::Post.new uri.request_uri, {'Content-Type' => 'application/json'}
      request.body = data
    elsif http_method.upcase == HTTP_PUT
      raise ArgumentError, 'Invalid data for HTTP PUT request' if nil_or_empty? data
      request = Net::HTTP::Put.new uri.request_uri, {'Content-Type' => 'application/json'}
      request.body = data
    elsif http_method.upcase == HTTP_PATCH
      raise ArgumentError, 'Invalid data for HTTP PATCH request' if nil_or_empty? data
      request = Net::HTTP::Patch.new uri.request_uri, {'Content-Type' => 'application/json'}
      request.body = data
    elsif http_method.upcase == HTTP_GET
      request = Net::HTTP::Get.new uri.request_uri, {'Accept' => 'application/json'}
    elsif http_method.upcase == HTTP_DELETE
      request = Net::HTTP::Delete.new uri.request_uri, {'Accept' => 'application/json'}
    else
      debug("Error: Invalid HTTP Method: #{http_method}")
    end

    # Add Authentication Information to Request (downloads still require CUP authentication)
    unless download_collector
      if auth == BASIC
        request.basic_auth resource[:user], resource[:password] unless download_collector
      elsif auth == TOKEN
        request['Authorization'] = generate_token(endpoint, http_method, data)
      end
    end

    # Execute Request and Return Response
    if connection.nil?
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.start
    else
      http = connection
    end

    if download_collector
      http.request(request).body
    else
      response = http.request(request)
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        alert e.message
        raise e
      end
    end
  end

  # Checks which form of authentication to perform for HTTP Request
  def check_auth
    if nil_or_empty?(resource[:account])
      raise ArgumentError, 'Account missing, may not be nil or empty'
    else
      if nil_or_empty?(resource[:access_id]) || nil_or_empty?(resource[:access_key])
        if check_basic_auth
          raise ArgumentError, 'Not enough information for Authentication. '\
          'Need either API Token Access ID & Key OR Username and Password'
        else
          return BASIC
        end
      else
        return TOKEN
      end
    end
  end

  def check_basic_auth
    nil_or_empty?(resource[:user]) || nil_or_empty?(resource[:password])
  end

  # Builds a Hash containing LogicMonitor-supported RESTful query parameters
  # filter: Filters the response according to the operator and value specified. Example: 'id>4'
  # fields: Filters the response to only include the following fields for each object
  # size: The number of results to display
  # patch_ields: If we are preparing to perform an HTTP PATCH, we need to specify which fields we are updating
  def build_query_params(filter=[], fields=[], size=-1, patch_fields=[])
    query_params = Hash.new
    unless nil_or_empty?(filter)
      query_params['filter'] = filter
    end
    unless nil_or_empty?(fields)
      if fields.is_a? Array
        query_params['fields'] = fields.join(',')
      elsif fields.is_a? String
        query_params['fields'] = fields
      else
        raise ArgumentError, 'Invalid fields parameter, must be string (single element) or array'
      end
    end
    unless size <= 0
      query_params['size'] = size
    end
    unless nil_or_empty?(patch_fields)
      query_params['patchFields'] = patch_fields.join(',')
    end
    query_params
  end

  # Helper method to generate a LMv1 API Token
  def generate_token(endpoint, http_method, data='')
    timestamp = DateTime.now.strftime('%Q')
    unsigned_data = "#{http_method.upcase}#{timestamp}#{data.to_s}#{endpoint}"
    signature = Base64.strict_encode64(
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), resource[:access_key], unsigned_data)
    ).strip
    "LMv1 #{resource[:access_id]}:#{signature}:#{timestamp}"
  end

  # Helper method to determine if an object is nil or empty
  def nil_or_empty?(obj)
    if obj.nil? || obj.empty?
      return true
    end
    false
  end

  # Helper method to determine if LogicMonitor RPC response is successful
  # resp: Response from LogicMonitor API
  # multi: If there could be multiple items, we should make sure items are not nil/empty
  # delete: If we are deleting something we expect data to be nil, so just check status
  def valid_api_response?(resp, multi=false, delete=false)
    if delete
      if resp['status'] == 200
        return true
      end
    end
    if resp['status'] == 200 && !nil_or_empty?(resp['data'])
      if multi
        unless nil_or_empty?(resp['data']['items'])
          return true
        end
        return false
      end
      return true
    end
    false
  end

  # Retrieve Agent by it's description field
  # connection: connection to use for executing API request
  # description: description of collector (usually defaults to its hostname)
  # fields: any fields that should be returned specifically (defaults to nil)
  def get_agent_by_description(connection, description, fields=nil)
    agents_json = rest(connection,
                       COLLECTORS_ENDPOINT,
                       HTTP_GET,
                       build_query_params("description:#{description}", fields, 1))
    valid_api_response?(agents_json, true) ? agents_json['data']['items'][0] : nil
  end

  # Retrieve Group via fullPath
  # connection: connection to use for executing API request
  # full_path: full path of group location (similar to file path)
  # fields: fields needed in request (to reduce overhead we can limit what LogicMonitor responds with)
  def get_device_group(connection, full_path, fields=nil)
    group_json = rest(connection,
                      'device/groups',
                      HTTP_GET,
                      build_query_params("fullPath:#{full_path}", fields, 1))

    valid_api_response?(group_json, true) ? group_json['data']['items'][0] : nil
  end

  # Builds JSON for creating or updating a LogicMonitor device group
  # full_path: full path of group location (similar to file path)
  # description: description of device group
  # properties: Hash containing name/value pairs for properties
  # disable_alerting: Enable / Disable alerting for devices in this group
  # parent_id: device group ID of parent group (root level device group ID == 1)
  def build_group_json(full_path, description, properties, disable_alerting, parent_id)
    path = full_path.rpartition('/')
    group_hash = {'name' => path[2]}
    group_hash['parentId'] = parent_id
    group_hash['disableAlerting'] = disable_alerting
    unless description.nil?
      group_hash['description'] = description
    end
    custom_properties = Array.new
    unless nil_or_empty?(properties)
      properties.each_pair do |key, value|
        custom_properties << {'name' => key, 'value' => value}
      end
      group_hash['customProperties'] = custom_properties
    end
    group_hash
  end

  # Handles creation of all device groups
  # connection: connection to use for executing API request
  # full_path: full path of group location (similar to file path)
  # description: description of device group
  # properties: Hash containing name/value pairs for properties
  # disable_alerting: Enable / Disable alerting for devices in this group
  def recursive_group_create(connection, full_path, description, properties, disable_alerting)
    path = full_path.rpartition('/')
    parent_path = path[0]
    debug "Checking for parent device group: #{path[2]}"
    parent_id = 1
    unless nil_or_empty?(parent_path)
      parent = get_device_group(parent_path, 'id')
      if nil_or_empty?(parent)
        parent_ret = recursive_group_create(connection, parent_path, nil, nil, true)
        unless parent_ret.nil?
          parent_id = parent_ret
        end
      else
        debug 'parent group exists'
        parent_id = parent['id']
      end
    end
    debug 'Creating Group: %s' % full_path
    add_device_group_json = rest(connection,
                                 DEVICE_GROUPS_ENDPOINT,
                                 HTTP_POST,
                                 nil,
                                 build_group_json(full_path, description, properties, disable_alerting, parent_id).to_json)
    add_device_group_json['data']['id'] if valid_api_response?(add_device_group_json)
  end
end