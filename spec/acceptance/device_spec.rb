require_relative '../spec_helper_acceptance'

RSpec.describe 'device definition' do
  context 'valid device definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'puppettest',
        access_id  => '9K3A362Bv2N9pGbfgA22',
        access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
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