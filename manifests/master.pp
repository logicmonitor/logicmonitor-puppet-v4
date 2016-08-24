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
