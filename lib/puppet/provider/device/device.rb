# device.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# Copyright 2016 LogicMonitor, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#         limitations under the License.
#

require 'openssl'
require 'net/http'
require 'net/https'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'logicmonitor'))

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
      debug 'Starting connection for account: %s' % account
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

  # Creates a Device for the specified resource
  def create
    start = Time.now
    debug "Creating device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    resource[:groups].each do |group|
      if nil_or_empty?(get_device_group(connection, group, 'id'))
        debug "Couldn't find parent group #{group}. Creating it."
        recursive_group_create(connection, group, nil, nil, false)
      end
    end
    add_device_response = rest(connection,
                               Puppet::Provider::Logicmonitor::DEVICES_ENDPOINT,
                               Puppet::Provider::Logicmonitor::HTTP_POST,
                               nil,
                               build_device_json(connection,
                                                 resource[:hostname],
                                                 resource[:display_name],
                                                 resource[:collector],
                                                 resource[:description],
                                                 resource[:groups],
                                                 resource[:properties],
                                                 resource[:disable_alerting]).to_json)
    alert(add_device_response) unless valid_api_response?(add_device_response)
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Delete a Device Record for the specified resource
  # API used: Rest
  def destroy
    start = Time.now
    debug "Removing device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    device = get_device_by_display_name(connection, resource[:display_name], 'id') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    if device
      delete_device_response = rest(connection,
                                    Puppet::Provider::Logicmonitor::DEVICE_ENDPOINT % device['id'],
                                    Puppet::Provider::Logicmonitor::HTTP_DELETE)
      alert(delete_device_response) unless valid_api_response?(delete_device_response)
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Checks if a Device exists in the LogicMonitor Account
  def exists?
    start = Time.now
    debug "Checking for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    device = get_device_by_display_name(connection, resource[:display_name], 'id') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    if nil_or_empty?(device)
      debug "Finished in #{(Time.now-start)*1000.0} ms"
      return false
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    true
  end

  # Retrieves display_name
  def display_name
    start = Time.now
    debug "Checking display_name for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    device = get_device_by_display_name(connection, resource[:display_name], 'displayName') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    device ? device['displayName'] : nil
  end

  # Updates display_name
  def display_name=(value)
    start = Time.now
    debug "Updating display_name on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    update_device(connection,
                  resource[:hostname],
                  value,
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Retrieves Description 
  def description
    start = Time.now
    debug "Checking description for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    device = get_device_by_display_name(connection, resource[:display_name], 'description') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    device ? device['description'] : nil
  end

  # Updates Description 
  def description=(value)
    start = Time.now
    debug "Updating description on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    update_device(connection,
                  resource[:hostname],
                  resource[:display_name],
                  resource[:collector],
                  value,
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Retrieves Collector 
  def collector
    start = Time.now
    debug "Checking collector for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    agent = get_agent_by_description(connection, resource[:collector], 'description')
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    agent ? agent['description'] : nil
  end

  # Updates Collector 
  def collector=(value)
    start = Time.now
    debug "Updating collector on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    update_device(connection,
                  resource[:hostname],
                  resource[:display_name],
                  value,
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  resource[:disable_alerting])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Retrieves disable_alerting setting
  def disable_alerting
    start = Time.now
    debug "Checking disable_alerting setting on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    device = get_device_by_display_name(connection, resource[:display_name], 'disableAlerting') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    device ? device['disableAlerting'].to_s : nil
  end

  # Updates disable_alerting setting
  def disable_alerting=(value)
    start = Time.now
    debug "Updating disable_alerting setting on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    update_device(connection,
                  resource[:hostname],
                  resource[:display_name],
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  resource[:properties],
                  value)
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Retrieves Group Membership information
  # Note: Device Groups may only be managed by this module if they are NOT dynamic
  def groups
    start = Time.now
    debug "Checking group memberships for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    group_list = []
    device = get_device_by_display_name(connection, resource[:display_name], 'hostGroupIds') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    if device
      device_group_ids = device['hostGroupIds'].split(',')
      device_group_filters = Array.new
      device_group_ids.each do |hg_id|
        device_group_filters << "id:#{hg_id}"
      end
      device_group_filters = device_group_filters.join '||'

      device_group_response = rest(connection,
                                   Puppet::Provider::Logicmonitor::DEVICE_GROUPS_ENDPOINT,
                                   Puppet::Provider::Logicmonitor::HTTP_GET,
                                   build_query_params(device_group_filters, %w(appliesTo fullPath)))

      if valid_api_response?(device_group_response,true)
        device_group_response['data']['items'].each do |device_group|
          group_list.push "#{device_group['fullPath']}" if nil_or_empty?(device_group['appliesTo'])
        end
      else
        alert 'Unable to get Device Groups'
      end
    else
      alert 'Unable to get Device'
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    group_list
  end

  # Update Group Membership information
  def groups=(value)
    start = Time.now
    debug "Updating the set of group memberships on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    value.each do |group|
      recursive_group_create(connection, group, nil, nil, false) unless get_device_group(connection, group, 'id')
    end
    update_device(connection,
                  resource[:hostname],
                  resource[:display_name],
                  resource[:collector],
                  resource[:description],
                  value,
                  resource[:properties],
                  resource[:disable_alerting])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Retrieve Device Properties
  def properties
    start = Time.now
    debug "Checking properties for device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    properties = Hash.new
    device = get_device_by_display_name(connection, resource[:display_name], 'id') ||
             get_device_by_hostname(connection, resource[:hostname], resource[:collector])
    if device
      device_properties = rest(connection,
                               Puppet::Provider::Logicmonitor::DEVICE_PROPERTIES_ENDPOINT % device['id'],
                               Puppet::Provider::Logicmonitor::HTTP_GET,
                               build_query_params('type:custom,name!:system.categories,name!:puppet.update.on',
                                                  'name,value'))
      if valid_api_response?(device_properties, true)
        device_properties['data']['items'].each do |property|
          name = property['name'].downcase
          value = property['value']
          if value.include?('********') && resource[:properties].has_key?(name)
            debug 'Found password property. Verifying'
            verify_device_property = rest(connection,
                                          Puppet::Provider::Logicmonitor::DEVICE_PROPERTIES_ENDPOINT % device['id'],
                                          Puppet::Provider::Logicmonitor::HTTP_GET,
                                          build_query_params("type:custom,name:#{name},value:#{value}", nil, 1))
            if valid_api_response?(verify_device_property)
              debug 'Property unchanged'
              value = resource[:properties][name]
            else
              debug 'Property changed'
            end
          end
          unless name == 'system.categories' || name == 'puppet.update.on'
            if (name == 'snmp.version' && resource[:properties]['snmp.version']) ||
                name != 'snmp.version'
              properties[name] = value
            end
          end
        end
      else
        alert device_properties
      end
    else
      alert device
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    properties
  end

  # Update Device Properties
  def properties=(value)
    start = Time.now
    debug "Updating properties on device: \"#{resource[:hostname]}\""
    connection = self.class.get_connection(resource[:account])
    update_device(connection,
                  resource[:hostname],
                  resource[:display_name],
                  resource[:collector],
                  resource[:description],
                  resource[:groups],
                  value,
                  resource[:disable_alerting])
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Helper method to simplify updating a device logic
  def update_device(connection, hostname, display_name, collector, description, groups, properties, disable_alerting)
    device = get_device_by_display_name(connection, display_name, 'id,scanConfigId,netflowCollectorId') ||
             get_device_by_hostname(connection, hostname, collector)
    update_device_hash = build_device_json(connection,
                                           hostname,
                                           display_name,
                                           collector,
                                           description,
                                           groups,
                                           properties,
                                           disable_alerting)
    if device
      update_device_hash['scanConfigId'] = device['scanConfigId'] unless device['scanConfigId'] == 0
      update_device_hash['netflowCollectorId'] = device['netflowCollectorId'] unless device['netflowCollectorId'] == 0
      update_device_response = rest(connection,
                                    Puppet::Provider::Logicmonitor::DEVICE_ENDPOINT % device['id'],
                                    Puppet::Provider::Logicmonitor::HTTP_PATCH,
                                    build_query_params(nil, nil, -1, update_device_hash.keys),
                                    update_device_hash.to_json)
      alert(update_device_response) unless valid_api_response?(update_device_response)
    end
  end

  # Helper method to build JSON for creating/updating a LogicMonitor Device via REST API
  def build_device_json(connection, hostname, display_name, collector, description, groups, properties, disable_alerting)
    device_hash = {}
    device_hash['name'] = hostname
    device_hash['displayName'] = display_name
    device_hash['preferredCollectorId'] = get_agent_by_description(connection, collector, 'id')['id'] unless nil_or_empty?(collector)
    device_hash['description'] = description unless nil_or_empty?(description)
    group_ids = Array.new
    groups.each do |group|
      group_ids << get_device_group(connection, group, 'id')['id'].to_s
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
    device_hash
  end

  # Retrieve device (fields) by it's display_name (unique)
  def get_device_by_display_name(connection, display_name, fields=nil)
    device_json = rest(connection,
                       Puppet::Provider::Logicmonitor::DEVICES_ENDPOINT,
                       Puppet::Provider::Logicmonitor::HTTP_GET,
                       build_query_params("displayName:#{display_name}", fields, 1))
    valid_api_response?(device_json, true) ? device_json['data']['items'][0] : nil

  end

  # Retrieve device (fields) by it's hostname & collector description (unique)
  def get_device_by_hostname(connection, hostname, collector)
    device_filters = ["name:#{hostname}"]
    device_filters << "collectorDescription:#{collector}"

    device_json = rest(connection,
                       Puppet::Provider::Logicmonitor::DEVICES_ENDPOINT,
                       Puppet::Provider::Logicmonitor::HTTP_GET,
                       build_query_params(device_filters.join(','), nil, 1))
    valid_api_response?(device_json, true) ? device_json['data']['items'][0] : nil
  end
end