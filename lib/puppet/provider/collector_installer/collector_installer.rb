# collector_installer.rb
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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'logicmonitor'))

Puppet::Type.type(:collector_installer).provide(:collector_installer, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the download and installation of a collector'

  # Creates a Collector Installer which downloads and installs a LogicMonitor Collector
  def create
    start = Time.now
    debug 'Downloading new collector installer.'
    collector = get_agent_by_description(nil, resource[:description], 'id')
    if collector
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_64.bin"
        arch = Puppet::Provider::Logicmonitor::LINUX_64
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_32.bin"
        arch = Puppet::Provider::Logicmonitor::LINUX_32
      end
      File.open(installation_binary, 'w+') do |file|
        file.write(rest(nil,
                        Puppet::Provider::Logicmonitor::COLLECTOR_DOWNLOAD_ENDPOINT % [collector['id'], arch],
                        Puppet::Provider::Logicmonitor::HTTP_GET,
                        nil,
                        nil,
                        true))
      end
      debug "Download Finished in #{(Time.now - start) * 1000.0} ms"
      install_start = Time.now
      debug 'Installing Collector'
      File.chmod(0755, installation_binary)
      `#{installation_binary} -y`
      debug "Collector Install took #{(Time.now-install_start)*1000.0} ms"
      debug "Total took #{(Time.now-start)*1000.0} ms"
    end
  end

  # Shuts down the Collector Service and Removes the installation binary from the device
  def destroy
    start = Time.now
    debug 'Uninstalling LogicMonitor collector'
    collector = get_agent_by_description(nil, resource[:description], 'id')
    if collector
      # Collector shutdown process
      `#{resource[:install_dir]}agent/bin/sbshutdown`
      `#{resource[:install_dir]}agent/bin/uninstall.pl`

      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_64.bin"
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{id}_32.bin"
      end
      File.delete installation_binary
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Checks that a collector installation binary exists
  def exists?
    start = Time.now
    debug 'Checking if Collector & Installation Binary Exists'
    collector = get_agent_by_description(nil, resource[:description], 'id')
    if collector
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_64.bin"
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_32.bin"
      end
      debug "Finished in #{(Time.now-start)*1000.0} ms"
      return File.exists?(installation_binary)
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    false
  end
end
