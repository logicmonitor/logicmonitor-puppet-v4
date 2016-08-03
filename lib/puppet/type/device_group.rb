# === Define: device_group
#
# This resource type defines a device group in your LogicMonitor account.
# The purpose is to introduce the following information into a puppetDB catalog for use by the LogicMonitor Master node.
#
# === Parameters
#
# [*namevar*]
#    Or "fullpath" 
#    Sets the path of the group. Path must start with a "/"
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
#    Overrides device level alert enable setting
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
# class { 'logicmonitor::device_group' :
#     full_path           => "puppet",
#     description         => "group description",
#     disable_alerting    => true,
#     properties          => {"testproperty" => "value"},
# }
#
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

Puppet::Type.newtype(:device_group) do
  @doc = 'Manage a LogicMonitor Device Group'
  ensurable

  newparam(:full_path, :namevar => true) do
    desc 'The full path including all parent groups. Format: \"/parent/child\"'
    validate do |value|
      if value.start_with?('/')
        value.slice! 0
      end
    end
  end

  newproperty(:description) do
    desc 'The long text description of a device group'
  end

  newproperty(:properties) do
    desc 'A hash where the keys represent the property names and the values represent the property values. '\
        '(e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})'
    defaultto {}
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, "#{value} is not a valid set of group properties. Properties must be in the format "\
                             "{\"propName0\"=>\"propValue0\",\"propName1\"=>\"propValue1\", ... }"
      end
    end
  end

  newproperty(:disable_alerting) do
    desc 'Set alerting at the device group level. A value of true will turn off alerting for all devices and subgroups '\
         'in that group due to LogicMonitor\'s inheritance rules. For further reading: '\
         'http://help.logicmonitor.com/using/i-got-an-alert-now-what/how-do-prevent-alerts-on-a-host-or-group/'
    newvalues(:true, :false)
  end

  newparam(:account) do
    desc 'This is the LogicMonitor account name'
    validate {|value| raise ArgumentError, 'account may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_id) do
    desc 'This is a LogicMonitor user\'s API Token Access ID.'
    validate {|value| raise ArgumentError, 'access_id may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_key) do
    desc 'This is a LogicMonitor user\'s API Token Access Key.'
    validate {|value| raise ArgumentError, 'access_key may not be nil or empty' if value.nil? || value.empty? }
  end
end
