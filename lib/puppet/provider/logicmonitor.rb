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
require 'Base64'
require 'date'

class Puppet::Provider::Logicmonitor < Puppet::Provider
  HTTP_POST = 'POST'
  HTTP_GET = 'GET'
  HTTP_PUT = 'PUT'
  HTTP_PATCH = 'PATCH'
  HTTP_DELETE = 'DELETE'

  # Execute a RESTful request to LogicMonitor
  # endpoint: RESTful endpoint to request
  # http_method: HTTP Method to use for RESTful request
  # query_params: Query Parameters to use in request (to modify results)
  # data: JSON data to send in HTTP POST RESTful requests
  # download: If we are executing a download the URL will be santaba/do instead of santaba/rest
  def rest(endpoint, http_method, query_params={}, data=nil, download=false)
    # Verify necessary Authentication Information
    verify_basic_auth

    # Build URI and add query Parameters
    if download
      uri = URI.parse("https://#{resource[:account]}.logicmonitor.com/santaba/do/logicmonitorsetup")
    else
      uri = URI.parse("https://#{resource[:account]}.logicmonitor.com/santaba/rest/#{endpoint}")
    end
    uri.query = URI.encode_www_form query_params

    # Build Request Object
    request = nil
    if http_method.upcase == HTTP_POST
      request = Net::HTTP::Post.new uri.request_uri, {'Content-Type' => 'application/json'}
      if nil_or_empty?(data)
        raise ArgumentError, 'Invalid data for HTTP POST request'
      end
      request.body = data
    elsif http_method.upcase == HTTP_PUT
      request = Net::HTTP::Put.new uri.request_uri, {'Content-Type' => 'application/json'}
      if nil_or_empty?(data)
        raise ArgumentError, 'Invalid data for HTTP PUT request'
      end
      request.body = data
    elsif http_method.upcase == HTTP_PATCH
      request = Net::HTTP::Patch.new uri.request_uri, {'Content-Type' => 'application/json'}
      if nil_or_empty?(data)
        raise ArgumentError, 'Invalid data for HTTP PATCH request'
      end
      request.body = data
    elsif http_method.upcase == HTTP_GET
      request = Net::HTTP::Get.new uri.request_uri
    elsif http_method.upcase == HTTP_DELETE
      request = Net::HTTP::Delete.new uri.request_uri
    else
      debug("Error: Invalid HTTP Method: #{http_method}")
    end

    # Add Authentication Information to Request (downloads still require CUP authentication)
    if download
      query = URI.decode_www_form(uri.query) << {'c' => resource[:account], 'u' => resource[:user], 'p' => resource[:password]}
      uri.query = URI.encode_www_form query
    else
      request.basic_auth resource[:user], resource[:password]
    end

    # Execute Request and Return Response
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    if download
      http.start {|http| http.request(request) }.body
    else
      JSON.parse(http.start {|http| http.request(request) }.body)
    end
  end

  # Builds a Hash containing LogicMonitor-supported RESTful query parameters
  # filter: Filters the response according to the operator and value specified. Example: 'id>4'
  # fields: Filters the response to only include the following fields for each object
  # size: The number of results to display
  def build_query_params(filter=[], fields=[], size=-1)
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
    query_params
  end

  # Helper method to generate a LMv1 API Token
  def generate_token(endpoint, http_method, data)
    timestamp = DateTime.now.strftime('%Q')
    unsigned_data = "#{http_method.upcase}#{timestamp}#{data.to_s}#{endpoint}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), resource[:access_key], unsigned_data)).strip
    "LMv1 #{resource[:access_id]}:#{signature}:#{timestamp}"
  end

  # Execute a RPC to LogicMonitor
  # action: RPC action to call
  # args: Query Parameters to RPC action
  def rpc(action, args={})
    verify_basic_auth
    if nil_or_empty?(action)
      raise ArgumentError, 'Invalid action specified, may not be nil or empty'
    end
    uri = URI.parse("https://#{resource[:account]}.logicmonitor.com/santaba/rpc/#{action}?")
    auth = {'c' => resource[:account], 'u' => resource[:user], 'p' => resource[:password]}
    args.merge! auth
    uri.query = URI.encode_www_form args
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      return JSON.parse(response.body)
    rescue SocketError => se
      alert "There was an issue communicating with #{url}, (#{se.message}). Please make sure everything is correct and try again."
    rescue Exception => e
      alert 'There was an unexpected issue.'
      alert e.message
      alert e.backtrace
    end
  end

  # Helper Method to ensure that the necessary basic authentication resources exist
  def verify_basic_auth()
    if nil_or_empty?(resource[:account])
      raise ArgumentError, 'Cannot retrieve account from resource'
    end
    if nil_or_empty?(resource[:user])
      raise ArgumentError, 'Cannot retrieve user from resource'
    end
    if nil_or_empty?(resource[:password])
      raise ArgumentError, 'Cannot retrieve password from resource'
    end
  end

  # Helper method to ensure that the necessary token authentication resources exist
  def verify_token_auth()
    if nil_or_empty?(resource[:account])
      raise ArgumentError, 'Cannot retrieve account from resource'
    end
    if nil_or_empty?(resource[:access_id])
      raise ArgumentError, 'Cannot retrieve access_id from resource'
    end
    if nil_or_empty?(resource[:access_key])
      raise ArgumentError, 'Cannot retrieve access_key from resource'
    end
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

  # Retrieve Group via fullPath
  # fullpath: full path of group location (similar to file path)
  # fields: fields needed in request (to reduce overhead we can limit what LogicMonitor responds with)
  def get_device_group(fullpath, fields=nil)
    group_json = rest('device/groups',
                      HTTP_GET,
                      build_query_params("fullPath:#{fullpath}", fields, 1))

    if valid_api_response?(group_json, true)
      return group_json['data']['items'][0]
    end
  end

  # Builds JSON for creating or updating a LogicMonitor device group
  # fullpath: full path of group location (similar to file path)
  # description: description of device group
  # properties: Hash containing name/value pairs for properties
  # disable_alerting: Enable / Disable alerting for devices in this group
  # parent_id: device group ID of parent group (root level device group ID == 1)
  def build_group_json(fullpath, description, properties, disable_alerting, parent_id)
    path = fullpath.rpartition('/')
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
    group_hash.to_json
  end

  # Handles creation of all device groups
  # fullpath: full path of group location (similar to file path)
  # description: description of device group
  # properties: Hash containing name/value pairs for properties
  # disable_alerting: Enable / Disable alerting for devices in this group
  def recursive_group_create(fullpath, description, properties, disable_alerting)
    path = fullpath.rpartition('/')
    parent_path = path[0]
    debug "Checking for parent device group: #{path[2]}"
    parent_id = 1
    unless nil_or_empty?(parent_path)
      parent = get_device_group(parent_path, 'id')
      if nil_or_empty?(parent)
        parent_ret = recursive_group_create(parent_path, nil, nil, true)
        unless parent_ret.nil?
          parent_id = parent_ret
        end
      else
        debug 'parent group exists'
        parent_id = parent['id']
      end
    end
    add_device_group_json = rest('/device/groups',
                               HTTP_POST,
                               nil,
                               build_group_json(fullpath, description, properties, disable_alerting, parent_id))
    add_device_group_json['data']['id'] if valid_api_response?(add_device_group_json)
  end
end