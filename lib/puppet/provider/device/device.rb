# device.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

require 'json'
require 'open-uri'

Puppet::Type.type(:device).provide(:device, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the creation, status, and deletion of devices'

  # Prefetch device instances. All device resources will use the same HTTPS connection
  def self.prefetch(instances)
    accounts = []
    @connections = {}
    instances.each do |name,resource|
      accounts.push(resource[:account])
    end
    accounts.uniq!
    accounts.each do |account|
      @connections[account] = start_connection "#{account}.logicmonitor.com"
    end
  end

  # Start a new HTTPS Connection for an account
  def self.start_connection(host)
    @connection_created_at = Time.now
    @connection = Net::HTTP.new(host, 443)
    @connection.use_ssl = true
    @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @connection.start
  end

  # Retrieve an existing HTTPS Connection for an account
  def self.get_connection(account)
    @connections[account]
  end

  # Verifies that the necessary device resource properties are specified.
  def verify_device_resources
    raise ArgumentError, 'Cannot retrieve displayname from resource' if nil_or_empty?(resource[:displayname])
    raise ArgumentError, 'Cannot retrieve hostname from resource' if nil_or_empty?(resource[:hostname])
    raise ArgumentError, 'Cannot retrieve collector from resource' if nil_or_empty?(resource[:collector])
  end

  # Creates a Device for the specified resource
  def create
    debug "Creating device: \"#{resource[:hostname]}\""
    verify_device_resources
    resource[:groups].each do |group|
      if nil_or_empty?(get_device_group(group, 'id'))
        debug "Couldn't find parent group #{group}. Creating it."
        recursive_group_create(group, nil, nil, true)
      end
    end
    add_device_response = rest('device/devices',
                               HTTP_POST,
                               nil,
                               build_device_json(resource[:hostname],
                                                 resource[:displayname],
                                                 resource[:collector],
                                                 resource[:description],
                                                 resource[:groups],
                                                 resource[:properties],
                                                 resource[:disable_alerting]))
    valid_api_response?(add_device_response) ? debug 'Successfully Created Device' : alert add_device_response
  end

  # Delete a Device Record for the specified resource
  # API's used: Rest
  def destroy
    debug "Removing device: \"#{resource[:hostname]}\""
    device = get_device_by_displayname(resource[:displayname], 'id') || get_device_by_hostname(resource[:hostname], resouce[:collector], 'id')
    if device
      delete_device_response = rest("device/devices/#{device['id']}", HTTP_DELETE)
      alert delete_device_response unless valid_api_response?(delete_device_response)
    end
  end

  # Checks if a Device exists in the LogicMonitor Account
  def exists?
    debug "Checking for device: \"#{resource[:hostname]}\""
    get_device_by_displayname(resource[:displayname], 'id') || get_device_by_hostname(resource[:hostname], resouce[:collector], 'id')
  end

  # Retrieves displayname 
  def displayname
    debug "Checking displayname for device: \"#{resource[:hostname]}\""
    device = get_device_by_displayname(resource[:displayname], 'displayedName') ||
             get_device_by_hostname(resource[:hostname], resource[:collector], 'displayedName')
    device ? return device['displayName'] : nil
  end

  # Updates displayname 
  def displayname=(value)
    debug "Updating displayname on device: \"#{resource[:hostname]}\""
    update_device(resource[:hostname],
                  value,
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
  end

  # Retrieves Description 
  def description
    debug "Checking description for device: \"#{resource[:hostname]}\""
    device = get_device_by_displayname(resource[:displayname], 'description') ||
             get_device_by_hostname(resource[:hostname], resource[:collector], 'description')
    device ? device['description'] : nil
  end

  # Updates Description 
  def description=(value)
    debug "Updating description on device: \"#{resource[:hostname]}\""
    update_device(resource[:hostname],
                  resource[:displayname],
                  resource[:collector],
                  value,
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
  end

  # Retrieves Collector 
  def collector
    debug "Checking collector for device: \"#{resource[:hostname]}\""
    agent = get_agent_by_description(resource[:collector], 'description')
    agent ? agent['description'] : nil
  end

  # Updates Collector 
  def collector=(value)
    debug "Updating collector on device: \"#{resource[:hostname]}\""
    update_device(resource[:hostname],
                  resource[:displayname],
                  value,
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
  end

  # Retrieves disable_alerting setting
  def disable_alerting
    debug "Checking disable_alerting setting on device: \"#{resource[:hostname]}\""
    device = get_device_by_displayname(resource[:displayname], 'disableAlerting') ||
             get_device_by_hostname(resource[:hostname], resource[:collector], 'disableAlerting')
    device ? device['disableAlerting'].to_s : nil
  end

  # Updates disable_alerting setting
  def disable_alerting=(value)
    debug "Updating disable_alerting setting on device: \"#{resource[:hostname]}\""
    update_device(resource[:hostname],
                  resource[:displayname],
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  value)
  end

  # Retrieves Group Membership information
  # Note: Device Groups may only be managed by this module if they are NOT dynamic
  def groups
    debug "Checking group memberships for device: \"#{resource[:hostname]}\""
    group_list = []
    device = get_device_by_displayname(resource[:displayname], 'hostGroupIds') ||
             get_device_by_hostname(resource[:hostname], resource[:collector], 'hostGroupIds')
    if device
      device_group_ids = device['hostGroupIds'].split(',')
      device_group_filters = Array.new
      device_group_ids.each do |hg_id|
        device_group_filters << "id:#{hg_id}"
      end
      device_group_filters = device_group_filters.join '||'

      device_group_response = rest('device/groups',
                                   HTTP_GET,
                                   build_query_params(device_group_filters, '||', %w(appliesTo fullPath)))

      if valid_api_response?(device_group_response,true)
        device_group_response['data']['items'].each do |device_group|
          group_list.push "/#{device_group['fullPath']}" if nil_or_empty?(device_group['appliesTo'])
        end
      else
        alert 'Unable to get Device Groups'
      end
    else
      alert 'Unable to get Device'
    end
    group_list
  end

  # Update Group Membership information
  def groups=(value)
    debug "Updating the set of group memberships on device: \"#{resource[:hostname]}\""
    value.each do |group|
      recursive_group_create(group, nil, nil, true) unless get_device_group(group, 'id')
    end
    update_device(resource[:hostname],
                  resource[:displayname],
                  resource[:collector],
                  resource[:description],
                  value,
                  resource[:properties],
                  resource[:disable_alerting])
  end

  # Retrieve Device Properties
  def properties
    debug "Checking properties for device: \"#{resource[:hostname]}\""
    properties = Hash.new
    device = get_device_by_displayname(resource[:displayname], 'id') ||
             get_device_by_hostname(resource[:hostname], resource[:collector], 'id')
    if device
      device_properties = rest("device/devices/#{device['id']}/properties",
                               HTTP_GET,
                               build_query_params('type:custom,name!:system.categories,name!:puppet.update.on',
                                                  'name,value'))
      if valid_api_response?(device_properties, true)
        device_properties['data']['items'].each do |property|
          name = property['name']
          value = property['value']
          if value.include?('********') && resource[:properties].has_key?(name)
            debug 'Found password property. Verifying'
            verify_device_property = rest("device/devices/#{device['id']}/properties",
                                          HTTP_GET,
                                          build_query_params("type:custom,name:#{name},value:#{value}", nil, 1))
            if valid_api_response?(verify_device_property)
              debug 'Property unchanged'
              value = resource[:properties][name]
            else
              debug 'Property changed'
            end
          end
          properties[name] = value
        end
      else
        alert device_properties
      end
    else
      alert device
    end
    properties
  end

  # Update Device Properties
  def properties=(value)
    debug "Updating properties on device: \"#{resource[:hostname]}\""
    update_device(resource[:hostname],
                  resource[:displayname],
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  value,
                  resource[:disable_alerting])
  end

  def update_device(hostname, displayname, collector, description, groups, properties, disable_alerting)
    device = get_device_by_displayname(displayname, 'id,scanConfigId,netflowCollectorId') ||
             get_device_by_hostname(hostname, collector, 'id,scanConfigId,netflowCollectorId')
    update_device_hash = build_device_json(hostname,
                                           displayname,
                                           collector,
                                           description,
                                           groups,
                                           properties,
                                           disable_alerting)
    if device
      update_device_hash = device['scanConfigId'] unless device['scanConfigId'] == 0
      update_device_hash = device['netflowCollectorId'] unless device['netflowCollectorId'] == 0
      update_device_response = rest("device/devices/#{device['id']}", HTTP_PATCH, nil, update_device_hash)
      alert update_device_response unless valid_api_response?(update_device_response)
    end
  end

  def build_device_json(hostname, displayname, collector, description, groups, properties, disable_alerting)
    device_hash = {}
    device_hash['name'] = hostname
    device_hash['displayName'] = displayname
    device_hash['preferredCollectorId'] = get_agent_by_description(collector, 'id')['id'] unless nil_or_empty?(collector)
    device_hash['description'] = description unless nil_or_empty?(description)
    group_ids = Array.new
    groups.each do |group|
      group_ids << get_device_group(group, 'id')['id'].to_s
    end
    device_hash['hostGroupIds'] = group_ids.join(',')
    device_hash['disableAlerting'] = disable_alerting
    custom_properties = Array.new
    unless nil_or_empty?(properties)
      properties.each_pair do |key, value|
        custom_properties << {'name' => key, 'value' => value}
      end
    end
    custom_properties << {'name' => 'puppet.update.on', 'value' => DateTime.now.to_s}
    device_hash['customProperties'] = custom_properties

    # The extra fields in the device_hash are required by the REST API but are default values
    device_hash['scanConfigId'] = 0
    device_hash['netflowCollectorId'] = 0
    device_hash.to_json
  end

  # Retrieve Agent by it's description field
  def get_agent_by_description(description, fields=nil)
    agents_json = rest('setting/collectors',
                       HTTP_GET,
                       build_query_params("description:#{description}", fields, 1))
    valid_api_response?(agents_json, true) ? agents_json['data']['items'][0] : alert agents_json
  end

  # Retrieve device (fields) by it's displayname (unique)
  def get_device_by_displayname(displayname, fields=nil)
    device_json = rest('device/devices',
                       HTTP_GET,
                       build_query_params("displayName:#{displayname}", fields, 1))
    valid_api_response?(device_json, true) ? device_json['data']['item'][0] : alert device_json
  end

  # Retrieve device (fields) by it's hostname & collector description (unique)
  def get_device_by_hostname(hostname, collector, fields=nil)
    device_filters = ["hostName:#{hostname}"]
    device_filters << "collectorDescription:#{collector}"

    device_json = rest('device/devices',
                       HTTP_GET,
                       build_query_params(device_filters.join(','), fields, 1))

    valid_api_response?(device_json, true) ? device_json['data']['item'][0] : alert device_json
  end
end