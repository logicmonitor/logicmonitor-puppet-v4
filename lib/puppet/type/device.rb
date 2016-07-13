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
# [*mode*]
#    Set the puppet management mode.
#    purge -
#
# [*opsnote*]
#    Boolean value setting whether to insert an OpsNote into your LogicMonitor account
#    when Puppet changes the device.
#
#
# === Examples
#
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

Puppet::Type.newtype(:device) do
  @doc = 'Manage a LogicMonitor Device'
  ensurable

  newparam(:hostname, :namevar => true) do
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
    newvalues(:true,:false)
    defaultto false
  end

  newproperty(:groups, :array_matching => :all) do
    desc 'An array where the entries are fullpaths of groups the device should be added to. e.g. [\"/parent/child\", \"/puppet_managed\"]'
    defaultto []
  end

  newproperty(:properties) do
    desc 'A hash where the keys represent the property names and the values represent the property values. '\
        '(e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})'
    defaultto {}
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, "#{value} is not a valid set of device properties. Properties must be in the format "\
                             "{\"propName0\"=>\"propValue0\",\"propName1\"=>\"propValue1\", ... }"
      end
    end
  end

  newparam(:account) do
    desc 'This is the LogicMonitor account name'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'account may not be nil or empty'
      end
    end
  end

  newparam(:user) do
    desc 'This is the LogicMonitor username'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'user may not be nil or empty'
      end
    end
  end

  newparam(:password) do
    desc 'This is the password for the LogicMonitor user specified'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'password may not be nil or empty'
      end
    end
  end
end
