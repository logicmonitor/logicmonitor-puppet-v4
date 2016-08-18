require_relative '../spec_helper_acceptance'

RSpec.describe 'device definition' do
  context 'valid device definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'lmsdacanay',
        access_id  => 'puppetadmin',
        access_key => 'marionette',
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
    it 'should should apply the manifest without errors' do
      apply_manifest(manifest, :catch_failures => true)
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be 0
    end
  end
end