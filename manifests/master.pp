# === Class: logicmonitor::master
#
# This class allows the LogicMonitor Portal management to be handled by a single device. We recommend having the device
# running PuppetDB as the only instance of this class. Handles the device and device group management.
#
# === Parameters
#
# This class has no paramters
#
# === Variables
#
# This class has no variables
#
# === Examples
#
# include logicmonitor::master
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

class logicmonitor::master (
  $account    = $logicmonitor::account,
  $access_id  = $logicmonitor::access_id,
  $access_key = $logicmonitor::access_key,
)inherits logicmonitor {

  Device_group <<| |>> {
    account    => $account,
    access_id  => $access_id,
    access_key => $access_key,
  }

  Device <<| |>> {
    account    => $account,
    access_id  => $access_id,
    access_key => $access_key,
  }
}
