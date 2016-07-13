# == Class logicmonitor::service
#
# This class is meant to be called from logicmonitor.
# It ensure the service is running.
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

class logicmonitor::service(
  $agent_service      = $logicmonitor::collector::agent_service,
  $watchdog_service   = $logicmonitor::collector::watchdog_service,
) inherits logicmonitor {

  validate_string($agent_service)
  validate_string($watchdog_service)

  service { $agent_service:
    ensure     => running,
    # enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Collector_installer[$::fqdn],
  }

  service { $watchdog_service:
    ensure     => running,
    # enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Collector_installer[$::fqdn],
  }

}
