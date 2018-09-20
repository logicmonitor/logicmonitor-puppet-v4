# === Define: device
#
# This resource type defines a device group in your LogicMonitor account.
# The purpose is to introduce the following information into a puppetDB catalog for use by the LogicMonitor Master node.
#
# === Parameters
#
# [*namevar*]
#    Or "hostname"
#    Sets the path of the group. Path must start with a "/"
#
# [*display_name*]
#    The LogicMonitor display name of the device
#
# [*collector*]
#    The LogicMonitor collector description
#
# [*description*]
#    Set the description shown in the LogicMonitor portal
#
# [*properties*]
#    Must be a Hash object of property names and associated values.
#    Set custom properties at the group level in the LogicMonitor Portal
#
# [*disable_alerting*]
#    Boolean value setting whether to deliver alerts on devices within this group.
#
# [*groups*]
#    Must be an Array object of group full path strings.
#
# [*account*]
#   LogicMonitor account. Required for API access.
#
# NOTE ON AUTHENTICATION: The LogicMonitor puppet module requires user api token access ID and key for authentication to
# our API. We no longer support Basic Authentication. It is recommended to use Hiera to abstract your API token credentials.
#
# [*access_id*]
#   LogicMonitor user API Token Access ID. Required for API access.
#
# [*access_key*]
#   LogicMonitor user API Token Access Key. Required for API Access.
#
#
# === Examples
#
# class { 'logicmonitor::device' :
#     hostname 			  => "192.168.0.1",
#     collector       => "collectordescription",
#     display_name		=> "node1",
#     description			=> "Sample LM Device",
#     properties			=> {"propertyname" => "value", "propertyvalue2" => "value2"},
#     groups				  => ["puppet"],
#     disable_alerting	=> false,
# }
#
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

Puppet::Type.newtype(:device) do
  @doc = 'Manage a LogicMonitor Device'
  ensurable

  newparam(:hostname, namevar: true) do
    desc 'The name of the device. Defaults to the fully qualified domain name. Accepts fully qualified domain name or ip address as input.'
  end

  newproperty(:display_name) do
    desc 'The way the device name appears in your LogicMonitor account.'
  end

  newproperty(:description) do
    desc 'The long text description of a device'
  end

  newproperty(:collector) do
    desc 'The description of the collector this device reports to.'
    validate do |value|
      unless value.class == String
        raise ArgumentError, "#{value} must be the unique string in the collector \"description\" field"
      end
    end
  end

  newproperty(:disable_alerting) do
    desc 'Enable / Disable alerting for this device'
    newvalues(:true, :false)
    defaultto false
  end

  newproperty(:groups, array_matching: :all) do
    desc 'An array where the entries are fullpaths of groups the device should be added to. e.g. [\"parent/child\", \"puppet_managed\"]'
    defaultto []
  end

  newproperty(:properties) do
    desc 'A hash where the keys represent the property names and the values represent the property values. '\
        '(e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})'
    defaultto {}
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, "#{value} is not a valid set of device properties. Properties must be in the format "\
                             '{"propName0"=>"propValue0","propName1"=>"propValue1", ... }'
      end
    end
  end

  newparam(:account) do
    desc 'This is the LogicMonitor account name'
    validate { |value| raise ArgumentError, 'account may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_id) do
    desc 'This is a LogicMonitor user\'s API Token Access ID.'
    validate { |value| raise ArgumentError, 'access_id may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_key) do
    desc 'This is a LogicMonitor user\'s API Token Access Key.'
    validate { |value| raise ArgumentError, 'access_key may not be nil or empty' if value.nil? || value.empty? }
  end
end
