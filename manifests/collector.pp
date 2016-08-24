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

class logicmonitor::collector(
  $install_dir      = '/usr/local/logicmonitor/',
  $agent_service    = 'logicmonitor-agent',
  $watchdog_service = 'logicmonitor-watchdog'
) inherits logicmonitor {
  contain logicmonitor::install
  contain logicmonitor::service
}
