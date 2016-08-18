require_relative '../spec_helper_acceptance'

RSpec.describe 'device collector definition' do
  context 'valid collector definition' do
    manifest = <<-EOM
      class { 'logicmonitor':
        account    => 'lmsdacanay',
        access_id  => 'puppetadmin',
        access_key => 'marionette',
      }
      include 'logicmonitor::master'
      include 'logicmonitor::collector'
    EOM
    it 'applies the manifest without errors' do
      apply_manifest(manifest, :catch_failures => true)
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be 0
    end
  end
end