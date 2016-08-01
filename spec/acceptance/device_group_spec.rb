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
      class { 'logicmonitor::device_group' :
        full_path        => 'puppet',
        description      => 'group description',
        disable_alerting => true,
        properties       => {'testproperty' => 'value'},
      }
    EOM

    apply_manifest(manifest, :catch_failures => true)
    expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be 0
  end
end