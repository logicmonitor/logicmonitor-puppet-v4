require 'spec_helper'

describe Puppet::Type.type(:collector_installer).provider(:collector_installer) do
  let :resource do
    Puppet::Type.type(:collector_installer).new(
      {
        :ensure      => :present,
        :description => 'UnitTestCollector',
        :install_dir => '/usr/local/logicmonitor/',
        :architecture => 'x86_64',
        :account     => 'puppettest',
        :access_id   => '9K3A362Bv2N9pGbfgA22',
        :access_key  => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
      }
    )
  end

  let :provider do
    resource.provider
  end

  describe 'exists?' do
    it 'checks if a collector exists in LogicMonitor, and that the installation binary exists' do
      VCR.use_cassette('collector_install/exists') do
        expect(provider.exists?).to be_falsey
      end
    end
  end

  describe 'create' do
    it 'downloads and installs a LogicMonitor collector binary' do
      allow(File).to receive(:open).and_yield(StringIO.new)
      allow(File).to receive(:chmod).and_return(true)
      allow(provider).to receive(:`).and_return(true) # stub out backticks

      VCR.use_cassette('collector_install/create', record: :new_episodes) do
        expect { provider.create }.to_not raise_error
      end
    end
  end

  describe 'destroy' do
    it 'removes the LogicMonitor collector binary' do
      allow(provider).to receive(:`).and_return(true) # stub out backticks
      allow(File).to receive(:delete).and_return(true)

      VCR.use_cassette('collector_install/destroy') do
        expect {provider.destroy }.to_not raise_error
      end
    end
  end
end
