require_relative '../spec_helper'

describe 'logicmonitor', :type => :class do
  context 'valid parameters' do
    let(:params) {
      {
          :account  => 'lmsdacanay',
          :user     => 'puppetadmin',
          :password => 'marionette',
      }
    }

    it { is_expected.to compile }
    it { is_expected.to have_resource_count(0) }
  end
end