require_relative '../spec_helper'

describe 'logicmonitor::install', :type => :class do
  context 'valid parameters' do
    let(:params) { {:install_dir => '/usr/local/logicmonitor'} }
    it { is_expected.to compile }
    it { is_expected.to have_resource_count(3) }

    it { is_expected.to contain_file('/usr/local/logicmonitor') }
    it { is_expected.to contain_collector(`hostname`.gsub("\n",'')) }
    it { is_expected.to contain_collector_installer(`hostname`.gsub("\n",'')) }
  end
end