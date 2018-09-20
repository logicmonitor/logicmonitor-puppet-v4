require_relative '../spec_helper_acceptance'

RSpec.describe 'device group definition' do
  context 'valid device_group definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'puppettest',
        access_id  => '9K3A362Bv2N9pGbfgA22',
        access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
      include 'logicmonitor::master'
      class { 'logicmonitor::device_group' :
        full_path        => 'puppet',
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
    EOM
    it 'applies the manifest without errors' do
      apply_manifest(manifest, catch_failures: true)
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be 0
    end
  end
end

RSpec.describe 'multiple device group definition' do
  context 'valid device_group definition for multiple groups' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'puppettest',
        access_id  => '9K3A362Bv2N9pGbfgA22',
        access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
      include 'logicmonitor::master'
      device_group { 'puppet1':
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
      device_group { 'puppet2':
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
    EOM
    it 'applies the manifest without errors' do
      apply_manifest(manifest, catch_failures: true)
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be 0
    end
  end
end

RSpec.describe 'nested device group definition' do
  context 'valid device_group definition for multiple groups' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'puppettest',
        access_id  => '9K3A362Bv2N9pGbfgA22',
        access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
      include 'logicmonitor::master'
      class { 'logicmonitor::device_group' :
        full_path        => 'puppet/test',
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
    EOM
    it 'applies the manifest without errors' do
      apply_manifest(manifest, catch_failures: true)
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be 0
    end
  end
end
