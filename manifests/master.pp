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

class logicmonitor::master inherits logicmonitor {

  Device_group <<| |>> {
    account  => $logicmonitor::account,
    user     => $logicmonitor::user,
    password => $logicmonitor::password,
  }

  Device <<| |>> {
    account  => $logicmonitor::account,
    user     => $logicmonitor::user,
    password => $logicmonitor::password,
  }
}
