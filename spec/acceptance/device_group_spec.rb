require_relative '../spec_helper_acceptance'

RSpec.describe 'device group definition' do
  context 'valid device_group definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'lmsdacanay',
        access_id  => 'puppetadmin',
        access_key => 'marionette',
      }
      include 'logicmonitor::master'
      class { 'logicmonitor::device_group' :
        full_path        => 'puppet',
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
    EOM
    it 'should apply the manifest without errors' do
      apply_manifest(manifest, :catch_failures => true)
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be 0
    end
  end
end