require_relative '../spec_helper_acceptance'

RSpec.describe 'device collector definition' do
  context 'valid collector definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'puppettest',
        access_id  => '9K3A362Bv2N9pGbfgA22',
        access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
      include 'logicmonitor::master'
      include 'logicmonitor::collector'
    EOM
    it 'applies the manifest without errors' do
      apply_manifest(manifest, catch_failures: true)
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be 0
    end
  end
end
