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
