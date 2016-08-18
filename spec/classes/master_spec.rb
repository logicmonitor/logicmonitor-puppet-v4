require_relative '../spec_helper'

describe 'logicmonitor::master', :type => :class do
  context 'valid parameters' do
    let(:params) {
      {
        :account    => 'lmsdacanay',
        :access_id  => '9Y2AKV2GI8HU56BG924Y',
        :access_key => '3bbjV(tu]478Bt-7Q%7(A)Pe32uR2PhN8rj)dR)9',
      }
    }
    it { is_expected.to compile }
    it { is_expected.to have_resource_count(0) }
  end
end