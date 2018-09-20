require_relative '../spec_helper'

describe 'logicmonitor::service', type: :class do
  context 'valid parameters' do
    let(:params) do
      {
        agent_service: 'logicmonitor-agent',
        watchdog_service: 'logicmonitor-watchdog',
      }
    end

    it {
      is_expected.to contain_service('logicmonitor-agent').with('ensure' => 'running',
                                                                'hasstatus' => 'true',
                                                                'hasrestart' => 'true')
    }
    it {
      is_expected.to contain_service('logicmonitor-watchdog').with('ensure' => 'running',
                                                                   'hasstatus' => 'true',
                                                                   'hasrestart' => 'true')
    }
    it { is_expected.to have_resource_count(2) }
  end
end
