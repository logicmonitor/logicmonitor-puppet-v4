require 'spec_helper'

describe 'logicmonitor::service', :type => :class do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context 'valid parameters', "on #{os}" do
      # include logicmonitor::install for the service to require the collector
      let(:pre_condition) { "class { 'logicmonitor::install': install_dir => '/path/to/install', }" }

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
      it { is_expected.to have_resource_count(5) }
    end
  end
end
