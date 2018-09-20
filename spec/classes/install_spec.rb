require_relative '../spec_helper'

describe 'logicmonitor::install', type: :class do
  context 'valid parameters' do
    let(:params) { { install_dir: '/usr/local/logicmonitor' } }

    it { is_expected.to compile }
    it { is_expected.to have_resource_count(3) }

    it {
      is_expected.to contain_file('/usr/local/logicmonitor').with('ensure' => 'directory',
                                                                  'mode' => '0755')
    }
    it {
      is_expected.to contain_collector(`hostname`.delete("\n")).with('ensure' => 'present',
                                                                     'account' => nil,
                                                                     'user'    => nil,
                                                                     'password' => nil)
    }
    it {
      is_expected.to contain_collector_installer(`hostname`.delete("\n")).with('ensure' => 'present',
                                                                               'install_dir' => '/usr/local/logicmonitor',
                                                                               'account' => nil,
                                                                               'user'    => nil,
                                                                               'password' => nil)
    }
  end
end
