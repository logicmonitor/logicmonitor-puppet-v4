# == Class logicmonitor::install
#
# This class is called from logicmonitor for install.
#
# Manages the creation, download and installation of
# a LogicMonitor collector on the specified node.
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#
class logicmonitor::install(
  $install_dir    = $logicmonitor::collector::install_dir
) inherits logicmonitor {

  validate_absolute_path($install_dir)

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
}
