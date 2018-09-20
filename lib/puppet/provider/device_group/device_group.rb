# device_group.rb
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

Puppet::Type.type(:device_group).provide(:device_group, parent: Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the creation, status, and deletion of device groups'

  # Prefetch device instances. All device resources will use the same HTTPS connection
  def self.prefetch(instances)
    accounts = []
    @connections = {}
    instances.each do |_name, resource|
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

  # Creates a Device Group based on parameters
  def create
    start = Time.now
    debug "Creating device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    recursive_group_create(connection,
                           resource[:full_path],
                           resource[:description],
                           resource[:properties],
                           resource[:disable_alerting])
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
  end

  # Deletes a Device Group
  def destroy
    start = Time.now
    debug("Deleting device group: \"#{resource[:full_path]}\"")
    connection = self.class.get_connection(resource[:account])
    device_group = get_device_group(connection, resource[:full_path], 'id')
    if device_group
      delete_device_group = rest(connection,
                                 Puppet::Provider::Logicmonitor::DEVICE_GROUP_ENDPOINT % device_group['id'],
                                 Puppet::Provider::Logicmonitor::HTTP_DELETE)
      valid_api_response?(delete_device_group) ? nil : alert(delete_device_group)
    end
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
  end

  # Verifies the existence of a device group
  def exists?
    start = Time.now
    debug "Checking if device group \"#{resource[:full_path]}\" exists"
    connection = self.class.get_connection(resource[:account])
    if resource[:full_path].eql?('/') || resource[:full_path].eql?('')
      true
    else
      device_group = get_device_group(connection, resource[:full_path])
      debug device_group unless nil_or_empty?(device_group)
      debug "Finished in #{(Time.now - start) * 1000.0} ms"
      nil_or_empty?(device_group) ? false : true
    end
  end

  # Retrieve Device Group Description
  def description
    start = Time.now
    debug "Checking description for device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    device_group = get_device_group(connection, resource[:full_path], 'description')
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
    device_group['description']
  end

  # Update Device Group Description
  def description=(value)
    start = Time.now
    debug "Updating description on device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    update_device_group(connection,
                        resource[:full_path],
                        value,
                        resource[:properties],
                        resource[:disable_alerting])
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
  end

  # Get disable_alerting status of Device Group
  def disable_alerting
    start = Time.now
    debug "Checking disable_alerting setting for device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    device_group = get_device_group(connection, resource[:full_path], 'disableAlerting')
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
    device_group['disableAlerting'].to_s
  end

  # Update disable_alerting status of Device Group
  def disable_alerting=(value)
    start = Time.now
    debug "Updating disable_alerting setting for device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    update_device_group(connection,
                        resource[:full_path],
                        resource[:description],
                        resource[:properties],
                        value)
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
  end

  # Retrieve Properties for device group (including password properties)
  def properties
    start = Time.now
    debug "Checking properties for device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    properties = {}
    device_group = get_device_group(connection, resource[:full_path], 'id')
    if device_group
      device_group_properties = rest(connection,
                                     Puppet::Provider::Logicmonitor::DEVICE_GROUP_PROPERTIES_ENDPOINT % device_group['id'],
                                     Puppet::Provider::Logicmonitor::HTTP_GET,
                                     build_query_params('type:custom,name!:system.categories,name!:puppet.update.on',
                                                        'name,value'))
      if valid_api_response?(device_group_properties, true)
        device_group_properties['data']['items'].each do |property|
          name = property['name']
          value = property['value']
          if value.include?('********') && resource[:properties].key?(name)
            debug 'Found password property. Verifying'
            verify_device_group_property = rest(connection,
                                                Puppet::Provider::Logicmonitor::DEVICE_GROUP_PROPERTIES_ENDPOINT % device_group['id'],
                                                Puppet::Provider::Logicmonitor::HTTP_GET,
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
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
    properties
  end

  # Update properties for a Device Group
  def properties=(value)
    start = Time.now
    debug "Updating properties for device group: \"#{resource[:full_path]}\""
    connection = self.class.get_connection(resource[:account])
    update_device_group(connection,
                        resource[:full_path],
                        resource[:description],
                        value,
                        resource[:disable_alerting])
    debug "Finished in #{(Time.now - start) * 1000.0} ms"
  end

  # Helper method for updating a Device Group via HTTP PATCH
  def update_device_group(connection, fullpath, description, properties, disable_alerting)
    device_group = get_device_group(connection, fullpath, 'id,parentId')
    device_group_hash = build_group_json(fullpath,
                                         description,
                                         properties,
                                         disable_alerting,
                                         device_group['parentId'])
    update_device_group = rest(connection,
                               Puppet::Provider::Logicmonitor::DEVICE_GROUP_ENDPOINT % device_group['id'],
                               Puppet::Provider::Logicmonitor::HTTP_PATCH,
                               build_query_params(nil, nil, -1, device_group_hash.keys),
                               device_group_hash.to_json)
    valid_api_response?(update_device_group) ? debug(update_device_group) : alert(update_device_group)
  end
end
