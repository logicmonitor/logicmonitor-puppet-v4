require_relative '../spec_helper'

describe 'logicmonitor::device', :type => :class do
  context 'valid parameters' do
    it { is_expected.to compile }
    it { is_expected.to have_resource_count(0) }
  end
end