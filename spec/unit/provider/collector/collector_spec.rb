require_relative '../../../spec_helper'
require 'json'

describe Puppet::Type.type(:collector).provider(:collector) do
  let :resource do
    Puppet::Type.type(:collector).new(
      {
        :ensure      => :present,
        :description => 'UnitTestCollector',
        :osfam       => 'RedHat',
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
    it 'checks if a collector record exists in LogicMonitor' do
      expect(provider.exists?).to be_falsey
    end
  end

  describe 'build_collector_json' do
    it 'builds valid json for creating a collector' do
      collector_json = JSON.parse(provider.build_collector_json('test description'))
      expect(collector_json['description']).to eq 'test description'
      expect(collector_json['backupAgentId']).to be 0
      expect(collector_json['enableFailBack']).to be_truthy
      expect(collector_json['resendIval']).to be 15
      expect(collector_json['suppressAlertClear']).to be_falsey
      expect(collector_json['escalatingChainId']).to be 0
      expect(collector_json['collectorGroupId']).to be 1
    end
  end

  describe 'create' do
    it 'creates a collector record in LogicMonitor' do
      expect(provider.create).to_not raise_error
    end
  end

  describe 'destroy' do
    it 'deletes a collector record in LogicMonitor' do
      expect(provider.destroy).to_not raise_error
    end
  end
end
