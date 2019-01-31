require 'spec_helper'

describe 'logicmonitor::service', :type => :class do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context 'valid parameters', "on #{os}" do
      let(:params) {
        {
            :agent_service    => 'logicmonitor-agent',
            :watchdog_service => 'logicmonitor-watchdog',
        }
      }
      it { is_expected.to contain_service('logicmonitor-agent').with({
          'ensure'  => 'running',
          'hasstatus' => 'true',
          'hasrestart'=> 'true',
        })
      }
      it { is_expected.to contain_service('logicmonitor-watchdog').with({
          'ensure'  => 'running',
          'hasstatus' => 'true',
          'hasrestart'=> 'true',
        })
      }
      it { is_expected.to have_resource_count(2) }
    end
  end
end
