# collector_installer.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

require 'json'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'logicmonitor'))

Puppet::Type.type(:collector_installer).provide(:collector_installer, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the download and installation of a collector'

  # Creates a Collector Installer which downloads and installs a LogicMonitor Collector
  def create
    debug 'Downloading new collector installer'
    collector = get_agent_by_description(nil, resource[:description], 'id')
    if collector
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_64.bin"
        arch = 64
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_32.bin"
        arch = 32
      end
      File.open(installation_binary, 'w+') do |file|
        download_query_params = {'id' => collector['id'], 'arch' => arch.to_s}
        file.write(rest(nil, '', Puppet::Provider::Logicmonitor::HTTP_GET, download_query_params, nil, true))
      end
      debug 'Installing Collector'
      File.chmod(0755, installation_binary)
      `#{installation_binary} -y`
    end
  end

  # Shuts down the Collector Service and Removes the installation binary from the device
  def destroy
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
  end

  # Checks that a collector installation binary exists
  def exists?
    debug 'Checking if Collector & Installation Binary Exists'
    collector = get_agent_by_description(nil, resource[:description], 'id')
    if collector
      if resource[:architecture].include?('64')
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_64.bin"
      else
        installation_binary = "#{resource[:install_dir]}logicmonitorsetup#{collector['id']}_32.bin"
      end
      return File.exists?(installation_binary)
    end
    false
  end
end
