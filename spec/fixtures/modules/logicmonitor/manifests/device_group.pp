# == Class: logicmonitor::device_group
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

class logicmonitor::device_group (
  $full_path        = '/',
  $description      = '',
  $disable_alerting = false,
  $properties       = {}
) inherits logicmonitor {
  # Validation
  validate_string($full_path)
  validate_string($description)
  validate_bool($disable_alerting)
  validate_hash($properties)

  # Create Resource
  @@device_group { $full_path:
    ensure           => present,
    description      => $description,
    disable_alerting => $disable_alerting,
    properties       => $properties,
  }
}