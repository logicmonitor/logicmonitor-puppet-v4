# === Class: Logicmonitor
#
# This is the top level class for managing your LogicMonitor portal through Puppet and PuppetDB. It also is the location
# where you specify the required credentials for both your LogicMonitor portal as well as configure access to a running
# PuppetDB.
#
# === Parameters
#
# [*account*]
#    Sets which portal to manage
#
# [*access_id*]
#    Access ID for a user's LMv1 API Token. This user must have sufficient permissions to create/modify devices, device
#    groups, and collectors.
#
# [*access_key*]
#    Access Key for a user's LMv1 API Token.
#
# === Variables
#
#    None
#
# === Examples
#
# With parameters:
#   class{ "logicmonitor":
#     account             => "mycompany",
#     user                => "me",
#     password            => "password",
#   }
#
# Using logicmonitor::config:
#   class( "logicmonitor": }
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

class logicmonitor(
  $account    = undef,
  $access_id  = undef,
  $access_key = undef,
) {
  validate_string($account)
  validate_string($access_id)
  validate_string($access_key)
}
