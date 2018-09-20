require_relative '../../../spec_helper'

describe Puppet::Type.type(:device).provider(:device) do
  let :resource do
    Puppet::Type.type(:device).new(
        {
            :ensure           => :present,
            :hostname         => '172.16.208.131',
            :display_name     => 'unittest',
            :collector        => 'agent.localdomain',
            :description      => 'unit testing',
            :disable_alerting => true,
            :groups           => ['unittest'],
            :properties       => {'test1' => 'val1'},
            :account          => 'puppettest',
            :access_id        => '9K3A362Bv2N9pGbfgA22',
            :access_key       => '+95[jRp)8{~]+34_Xr5hk5ga47cvAp4!vRv]2b6%',
        }
    )
  end

  let :provider do
    resource.provider
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.prefetch({'device' => resource})
    end
  end

  describe 'self.start_connection' do
    it 'creates a https connection' do
      expect(provider.class.start_connection('puppettest.logicmonitor.com')).to be_truthy
    end
  end

  describe 'self.get_connection' do
    it 'retrieves a https connection for account' do
      expect(provider.class.get_connection('puppettest')).to be_truthy
      expect(provider.class.get_connection('puppettest')).to be_an_instance_of Net::HTTP
    end
  end

  describe 'exists?' do
    it 'checks if device exists' do
      expect(provider.exists?).to be_falsey
    end
  end

  describe 'create' do
    it 'creates a device' do
      expect { provider.create }.to_not raise_error
    end
  end

  describe 'update_device' do
    it 'updates a device' do
      groups = ['unittest']
      props = {'test1' => 'val1'}
      expect {
        provider.update_device(nil,
                               '172.16.208.131',
                               'unittest',
                               'agent.localdomain',
                               'unit testing',
                               groups,
                               props,
                               true)
      }.to_not raise_error
    end
  end

  describe 'build_device_json' do
    it 'builds device json successfully' do
      groups = ['unittest']
      props = {'test1' => 'val1'}
      device_hash = provider.build_device_json(nil,
                                               '172.16.208.131',
                                               'unittest',
                                               'agent.localdomain',
                                               'unit testing',
                                               groups,
                                               props,
                                               true)

      # Note that we don't test actual value for preferredCollectorId and hostGroupIds
      # These fields are queried from logicmonitor (using methods that are tested in the logicmonitor_spec)
      expect(device_hash['name']).to be_an_instance_of String
      expect(device_hash['name']).to eq '172.16.208.131'
      expect(device_hash['name']).to be_an_instance_of String
      expect(device_hash['displayName']).to eq 'unittest'
      expect(device_hash['preferredCollectorId']).to be_an_instance_of Fixnum
      expect(device_hash['description']).to eq 'unit testing'
      expect(device_hash['hostGroupIds']).to be_an_instance_of String
      expect(device_hash['disableAlerting']).to be_truthy
      expect(device_hash['customProperties']).to be_an_instance_of Array
      expect(device_hash['customProperties'][0]).to be_an_instance_of Hash
      expect(device_hash['customProperties'][0]['name']).to eq 'test1'
      expect(device_hash['customProperties'][0]['value']).to eq 'val1'
      expect(device_hash['customProperties'][1]).to be_an_instance_of Hash
      expect(device_hash['customProperties'][1]['name']).to eq 'puppet.update.on'
      expect(device_hash['customProperties'][1]['value']).to_not be_nil
      expect(device_hash['scanConfigId']).to be 0
      expect(device_hash['netflowCollectorId']).to be 0
    end
  end

  describe 'get_device_by_display_name' do
    it 'retrieves the device successfully' do
      device = provider.get_device_by_display_name(nil, 'unittest', 'displayName')
      expect(device).to be_an_instance_of Hash
      expect(device['displayName']).to eq 'unittest'
    end
  end

  describe 'get_device_by_hostname' do
    it 'retrieves the device successfully' do
      device = provider.get_device_by_hostname(nil, '172.16.208.131', 'agent.localdomain')
      expect(device).to be_an_instance_of Hash
      expect(device['name']).to eq '172.16.208.131'
      expect(device['collectorDescription']).to eq 'agent.localdomain'
    end
  end

  describe 'display_name' do
    it 'retrieves the device\'s display_name' do
      expect(provider.display_name).to eq 'unittest'
    end
  end

  describe 'display_name=' do
    it 'updates the device\'s display_name' do
      expect { provider.display_name=('updatedunittest') }.to_not raise_error
    end
  end

  describe 'description' do
    it 'retrieves the device\'s description' do
      expect(provider.description).to eq 'unit testing'
    end
  end

  describe 'description=' do
    it 'updates the device\'s description' do
      expect { provider.description=('updated unit testing') }.to_not raise_error
    end
  end

  describe 'collector' do
    it 'retrieves the device\'s collector description' do
      expect(provider.collector).to eq 'agent.localdomain'
    end
  end

  describe 'collector=' do
    it 'updates the device\'s collector description' do
      expect { provider.collector=('puppet.localdomain') }.to_not raise_error
    end
  end

  describe 'disable_alerting' do
    it 'retrieves the device\'s disable_alerting setting' do
      expect(provider.disable_alerting).to eq 'true'
    end
  end

  describe 'disable_alerting=' do
    it 'updates the device\'s disable_alerting setting' do
      expect { provider.disable_alerting=(false) }.to_not raise_error
    end
  end

  describe 'groups' do
    it 'retrieves the device\'s group(s)' do
      groups = provider.groups
      expect(groups).to be_an_instance_of Array
      expect(groups.first).to eq 'unittest'
    end
  end

  describe 'groups=' do
    it 'updates the device\'s group(s)' do
      groups = ['unittest', 'unittest2']
      expect { provider.groups=(groups) }.to_not raise_error
    end
  end

  describe 'properties' do
    it 'retrieves the device\'s properties' do
      properties = provider.properties
      expect(properties).to be_an_instance_of Hash
      expect(properties.keys.first).to eq 'test1'
      expect(properties.values.first).to eq 'val1'
    end
  end

  describe 'properties=' do
    it 'updates the device\'s propreties' do
      properties = {'test1' => 'val1', 'test2' => 'val2'}
      expect { provider.properties=(properties) }.to_not raise_error
    end
  end

  describe 'destroy' do
    it 'destroys a device' do
      expect { provider.destroy }.to_not raise_error
    end
  end
end
