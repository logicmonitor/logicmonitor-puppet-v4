# == Class logicmonitor::install
#
# This class is called from logicmonitor for install.
#
# Manages the creation, download and installation of
# a LogicMonitor collector on the specified node.
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
    ensure     => present,
    osfam      => $::osfamily,
    account    => $logicmonitor::account,
    access_id  => $logicmonitor::access_id,
    access_key => $logicmonitor::access_key,
  }

  collector_installer {$::fqdn:
    ensure       => present,
    install_dir  => $install_dir,
    architecture => $::architecture,
    account      => $logicmonitor::account,
    access_id    => $logicmonitor::access_id,
    access_key   => $logicmonitor::access_key,
    require      => Collector[$::fqdn],
  }
}
