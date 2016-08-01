require_relative '../spec_helper_acceptance'

describe 'device group definition' do
  context 'valid device_group definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account  => 'lmsdacanay',
        user     => 'puppetadmin',
        password => 'marionette',
      }
      include 'logicmonitor::master'
      class { 'logicmonitor::device' :
        hostname         => '192.168.0.1',
        display_name     => 'node1',
        description      => 'Sample LM Device',
        properties       => {
          'propertyname'   => 'value',
          'propertyvalue2' => 'value2'
        },
        groups           => ['puppet'],
        disable_alerting => false,
      }
    EOM

    apply_manifest(manifest, :catch_failures => true)
    expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be 0
  end
end