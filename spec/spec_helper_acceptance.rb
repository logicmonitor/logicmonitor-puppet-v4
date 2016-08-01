require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do
  install_puppet
end

RSpec.configure do |c|
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes
  c.before :suite do
    puppet_module_install(:source => project_root, :module_name => 'logicmonitor')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-puppetdb'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
