require_relative '../spec_helper'

describe 'logicmonitor::master', :type => :class do
  context 'valid parameters' do
    let(:params) {
      {
        :account    => 'puppettest',
        :access_id  => '9K3A362Bv2N9pGbfgA22',
        :access_key => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
    }
    it { is_expected.to compile }
    it { is_expected.to have_resource_count(0) }
  end
end