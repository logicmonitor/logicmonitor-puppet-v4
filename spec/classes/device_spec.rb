require 'spec_helper'

describe 'logicmonitor::device', :type => :class do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context 'valid parameters', "on #{os}" do
      it { is_expected.to compile }
      it { is_expected.to have_resource_count(0) }
    end
  end
end
