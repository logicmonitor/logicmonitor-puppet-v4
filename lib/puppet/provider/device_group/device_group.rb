# device_group.rb
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

Puppet::Type.type(:device_group).provide(:device_group, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the creation, status, and deletion of device groups'

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


  def create
    debug "Creating device group: \"#{resource[:fullpath]}\""
    recursive_group_create(resource[:fullpath], resource[:description], resource[:properties], resource[:alertenable])
  end

  def destroy
    debug("Deleting device group: \"#{resource[:fullpath]}\"")
    device_group = get_group(resource[:fullpath], 'id')
    if device_group
      delete_device_group = rest("/device/groups/#{device_group['id']}", HTTP_DELETE)
      valid_api_response?(delete_device_group) ? nil : alert delete_device_group
    end
  end

  def exists?
    debug "Checking if device group \"#{resource[:fullpath]}\" exists"
    if resource[:fullpath].eql?('/')
      true
    else
      nil_or_empty?(get_group(resource[:fullpath])) ? false : true
    end
  end

  def description
    debug "Checking description for device group: \"#{resource[:fullpath]}\""
    get_device_group(resource[:fullpath],'description')['description']
  end

  def description=(value)
    debug "Updating description on device group: \"#{resource[:fullpath]}\""
    update_device_group(resource[:fullpath],
                        value,
                        resource[:properties],
                        resource[:alertenable])
  end

  def disable_alerting
    debug "Checking disable_alerting setting for device group: \"#{resource[:fullpath]}\""
    group = get_device_group(resource[:fullpath],'disableAlerting')
    group['disableAlerting'].to_s
  end

  def disable_alerting=(value)
    debug "Updating disable_alerting setting for device group: \"#{resource[:fullpath]}\""
    update_device_group(resource[:fullpath],
                        resource[:description],
                        resource[:properties],
                        value)
  end

  #
  # Property functions for checking and setting properties on a host group
  #
  def properties
    debug "Checking properties for device group: \"#{resource[:fullpath]}\""
    properties = Hash.new
    device_group = get_device_group(resource[:fullpath], 'id')
    if device_group
      device_group_properties = rest("device/groups/#{device_group['id']}/properties",
                                     HTTP_GET,
                                     build_query_params('type:custom,name!:system.categories,name!:puppet.update.on',
                                                        'name,value'))
      if valid_api_response?(device_group_properties, true)
        device_group_properties['data']['items'].each do |property|
          name = property['name']
          value = property['value']
          if value.include?('********') && resource[:properties].has_key?(name)
            debug 'Found password property. Verifying'
            verify_device_group_property = rest("device/groups/#{device_group['id']}/properties",
                                                HTTP_GET,
                                                build_query_params("type:custom,name:#{name},value:#{value}", nil, 1))
            if valid_api_response?(verify_device_group_property)
              debug 'Property unchanged'
              value = resource[:properties][name]
            else
              debug 'Property changed'
            end
          end
          properties[name] = value
        end
      else
        alert device_group_properties
      end
    else
      alert device_group
    end
    properties
  end

  def properties=(value)
    debug "Updating properties for device group: \"#{resource[:fullpath]}\""
    update_device_group(resource[:fullpath],
                        resource[:description],
                        value,
                        resource[:disable_alerting])
  end

  def update_device_group(fullpath, description, properties, disable_alerting)
    group = get_group(fullpath, 'id,parentId')
    group_json = build_group_json(fullpath,
                                  description,
                                  properties,
                                  disable_alerting,
                                  group['parentId'])
    update_device_group = rest("device/groups/#{group['id']}", HTTP_PATCH, nil, group_json)
    valid_api_response?(update_device_group) ? debug update_device_group : alert update_device_group
  end
end
