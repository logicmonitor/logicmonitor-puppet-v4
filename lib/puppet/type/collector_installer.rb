# === Define: collector_installer
#
# Manage your LogicMonitor collectors. (Client side)
# This resource type allows the provider to download and run an installer for a LogicMonitor collector on the local machine.
# Requires a collector to have been created for this device. (see collector resource type)
#
# === Parameters
#
# [*namevar*]
#   Or "description"
#   Sets the description of the collector in your LogicMonitor Account.
#   Must be unique, and preferred usage is the node's fully-qualified domain name.
#
# [*install_dir*]
#   The location to place the downloaded installer as well as to place the config files and binaries for the LogicMonitor collector after installation.
#
# [*architecture*]
#   This sets the type of installer binary to download. Depending on the architechture of the system (32-bit and 64-bit are the only supported architectures) the correspoding binary will be downloaded.
#   Required as the installer binary includes a bundled JDK which needs to have the correct architecture.
#
# [*account*]
#   LogicMonitor account. Required for API access.
#
# NOTE ON AUTHENTICATION: The LogicMonitor puppet module requires user api token access ID and key for authentication to
# our API. We no longer support Basic Authentication. It is recommended to use Hiera to abstract your API token credentials.
#
# [*access_id*]
#   LogicMonitor user API Token Access ID. Required for API access.
#
# [*access_key*]
#   LogicMonitor user API Token Access Key. Required for API Access.
#
# === Examples
#
#   include logicmonitor::collector
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

Puppet::Type.newtype(:collector_installer) do
  @doc = 'Download and Install a LogicMonitor Collector'
  ensurable

  newparam(:description) do
    isnamevar
    desc 'This is the name property. This is the collector description. Should be unique and tied to the host'
  end

  newparam(:install_dir) do
    desc 'Location to look for/place the installer'
  end

  newparam(:architecture) do
    desc 'The architecture of the system. Either 64 or 32.'
    validate do |value|
      unless value.include?('64') || value.include?('32')
        raise ArgumentError, '%s is not a valid architecture' % value
      end
    end
  end

  newparam(:account) do
    desc 'This is the LogicMonitor account name'
    validate { |value| raise ArgumentError, 'account may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_id) do
    desc 'This is a LogicMonitor user\'s API Token Access ID.'
    validate { |value| raise ArgumentError, 'access_id may not be nil or empty' if value.nil? || value.empty? }
  end

  newparam(:access_key) do
    desc 'This is a LogicMonitor user\'s API Token Access Key.'
    validate { |value| raise ArgumentError, 'access_key may not be nil or empty' if value.nil? || value.empty? }
  end
end
