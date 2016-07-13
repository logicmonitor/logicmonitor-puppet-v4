# === Class: logicmonitor::collector
#
# Manages the creation, download and installation of a LogicMonitor collector on the specified node.
#
# === Parameters
#
# [install_dir]
#    This is an optional parameter to chose the location to install the LogicMonitor collector
#
# === Variables
#
#    No collector specific variables
#
# === Examples
#
# include logicmonitor::collector
# class { 'logicmoniotor::collector':}
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

class logicmonitor::collector(
  $install_dir      = '/usr/local/logicmonitor/',
  $agent_service    = 'logicmonitor-agent',
  $watchdog_service = 'logicmonitor-watchdog'
) inherits logicmonitor {
  contain logicmonitor::install
  contain logicmonitor::service
}
