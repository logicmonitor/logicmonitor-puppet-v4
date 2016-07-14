require_relative '../spec_helper'

describe 'logicmonitor::collector', :type => :class do
  context 'with all parameters' do
    it { is_expected.to compile }

    it { is_expected.to contain_class('logicmonitor::install') }
    it { is_expected.to contain_class('logicmonitor::service') }

    it { is_expected.to have_resource_count(5) }
  end
end
