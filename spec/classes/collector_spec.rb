require 'spec_helper'

describe 'logicmonitor::collector', :type => :class do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context 'with all parameters', "on #{os}" do
      it { is_expected.to compile }
  
      it { is_expected.to contain_class('logicmonitor::install') }
      it { is_expected.to contain_class('logicmonitor::service') }
  
      it { is_expected.to have_resource_count(5) }
    end
  end
end
