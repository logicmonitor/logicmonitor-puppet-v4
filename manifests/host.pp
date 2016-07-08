# === Class: logicmonitor::host
#
# This class flags nodes which should be added
# to monitoring in a LogicMonitor portal.
# In addition to flagging the node,
# it also sets how the node will appear in the portal
# with regards to display name,
# associated host groups, alerting and properties.
#
# === Parameters
#
# [*collector*]
#    Required
#    Sets which collector will be handling the data for this device.
#    Accepts a fully qualified domain name. A collector with the
#    associated fully qualified domain name must exist in the
#    Settings -> Collectors tab of the LogicMonitor Portal.
#
# [*hostname*]
#    Defaults to the fully qualified domain
#    name of the node.
#    Provides the default host name and display name
#    values for the LogicMonitor portal
#    Can be overwritten by the $display_name and
#    $ip_address parameters
#
# [*displayname*]
#    Defaults to the value of $host_name.
#    Set the display name that this node will appear
#    within the LogicMonitor portal
#
# [*description*]
#    Defaults to "UNSET"
#    Set the host description shown in the LogicMonitor Portal
#
# [*alertenable*]
#    Defaults to true
#    Set whether alerts will be sent for the host.
#    Note: If a parent group is set to alertenable=false
#    alerts for child hosts will be turned off as well.
#
# [*groups*]
#    Must be an Array of group names.
#    e.g. groups => ["/puppetlabs", "/puppetlabs/puppetdb"]
#    Default to empty.
#    Set the list of groups this host belongs to.
#    If left empty will add at the global level.
#    To add to a subgroup, the full path name must be specified.
#
# [*properties*]
#    Must be a Hash of property names and associated values.
#    e.g. {"mysql.user" => "youthere", "mysql.port" => 1234}
#    Default to empty
#    Set custom properties at the host level
#
# [*opsnote*]
#    Boolean. Defaults to false.
#    When true will insert an OpsNote in your
#    LogicMonitor account when Puppet updates the host.
#
#  === Examples
#
#  class {'logicmonitor::host':
#          collector => "qa1.domain.com",
#          hostname => "10.171.117.9",
#          groups => ["/puppetlabs", "/puppetlabs/puppetdb"],
#          properties => {"snmp.community" => "puppetlabs"},
#          description => "This is an instance for this deployment",
#        }
#
#  class {'logicmonitor::host':
#          collector => $fqdn,
#          display_name => "MySQL Production Host 1",
#          groups => ["/puppet", "/production", "/mysql"],
#          properties => {"mysql.port" => 1234},
#        }
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

class logicmonitor::host(
  $collector        = $::fqdn,
  $hostname         = $::fqdn,
  $displayname      = $::fqdn,
  $description      = '',
  $alertenable      = true,
  $groups           = [],
  $properties       = {},
) inherits logicmonitor {

  @@device{$hostname:
    ensure       => present,
    collector    => $collector,
    displayname  => $displayname,
    description  => $description,
    alertenable  => $alertenable,
    groups       => $groups,
    properties   => $properties,
  }
}
