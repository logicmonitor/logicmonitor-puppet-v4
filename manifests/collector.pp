# === Class: logicmonitor::collector
#
# Manages the creation, download and installation of
# a LogicMonitor collector on the specified node.
#
# === Parameters
#
# [install_dir]
#    This is an optional parameter to chose the
#    location to install the LogicMonitor collector
#
# === Variables
#
#    No collector specific variables
#
# === Examples
#
# include logicmonitor::collector
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
  $install_dir='/usr/local/logicmonitor/'
) inherits logicmonitor {

  file { $install_dir:
    ensure => directory,
    mode   => '0755',
    before => Collector_installer[$::fqdn],
  }

  collector { $::fqdn:
    ensure   => present,
    osfam    => $::osfamily,
    account  => $logicmonitor::account,
    user     => $logicmonitor::user,
    password => $logicmonitor::password,
  }

  collector_installer {$::fqdn:
    ensure       => present,
    install_dir  => $install_dir,
    architecture => $::architecture,
    account      => $logicmonitor::account,
    user         => $logicmonitor::user,
    password     => $logicmonitor::password,
    require      => Collector[$::fqdn],
  }

  service{'logicmonitor-agent':
    ensure  => running,
    require => Collector_installer[$::fqdn],
  }

  service{'logicmonitor-watchdog':
    ensure  => running,
    require => Collector_installer[$::fqdn],
  }
}
