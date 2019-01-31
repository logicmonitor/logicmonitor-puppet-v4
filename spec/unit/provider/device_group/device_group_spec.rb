require 'spec_helper'

describe Puppet::Type.type(:device_group).provider(:device_group) do
  let :resource do
    Puppet::Type.type(:device_group).new(
        {
            :ensure           => :present,
            :full_path        => 'groupunittest',
            :description      => 'unit testing',
            :disable_alerting => true,
            :properties       => {'testgroup1' => 'groupval1'},
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
      provider.class.prefetch({'device_group' => resource})
    end
  end

  describe 'self.start_connection' do
    it 'creates a https connection' do
      expect(provider.class.start_connection('lmsdacanay.logicmonitor.com')).to be_truthy
    end
  end

  describe 'self.get_connection' do
    it 'retrieves a https connection for account' do
      expect(provider.class.get_connection('lmsdacanay')).to be_an_instance_of Net::HTTP
    end
  end

  describe 'exists?' do
    it 'checks if device_group exists' do
      VCR.use_cassette('devicegroup/exists') do
        expect(provider.exists?).to be_falsey
      end
    end
  end

  describe 'create' do
    it 'creates a device_group' do
      VCR.use_cassette('devicegroup/create') do
        expect { provider.create }.to_not raise_error
      end
    end
  end

  describe 'update_device_group' do
    it 'updates a device_group' do
      groups = ['unittest']
      props = {'testgroup1' => 'groupval1'}
      VCR.use_cassette('devicegroup/update') do
        expect {
          provider.update_device_group(nil,
                                      'groupunittest',
                                      'unit testing',
                                      props,
                                      true)
        }.to_not raise_error
      end
    end
  end

  describe 'description' do
    it 'retrieves the device_group\'s description' do
      VCR.use_cassette('devicegroup/get_description') do
        expect(provider.description).to eq 'unit testing'
      end
    end
  end

  describe 'description=' do
    it 'updates the device_group\'s description' do
      VCR.use_cassette('devicegroup/set_description') do
        expect { provider.description=('updated unit testing') }.to_not raise_error
      end
    end
  end

  describe 'disable_alerting' do
    it 'retrieves the device_group\'s disable_alerting setting' do
      VCR.use_cassette('devicegroup/get_disable_alerting') do
        expect(provider.disable_alerting).to eq 'true'
      end
    end
  end

  describe 'disable_alerting=' do
    it 'updates the device_group\'s disable_alerting setting' do
      VCR.use_cassette('devicegroup/set_disable_alerting') do
        expect { provider.disable_alerting=(false) }.to_not raise_error
      end
    end
  end

  describe 'properties' do
    it 'retrieves the device_group\'s properties' do
      properties = nil
      VCR.use_cassette('devicegroup/get_properties') do
        properties = provider.properties
      end
      expect(properties).to be_an_instance_of Hash
      expect(properties.keys.first).to eq 'testgroup1'
      expect(properties.values.first).to eq 'groupval1'
    end
  end

  describe 'properties=' do
    it 'updates the device_group\'s propreties' do
      properties = {'test1' => 'val1', 'test2' => 'val2'}
      VCR.use_cassette('devicegroup/set_properties') do
        expect { provider.properties=(properties) }.to_not raise_error
      end
    end
  end

  describe 'destroy' do
    it 'destroys a device_group' do
      VCR.use_cassette('devicegroup/destroy') do
        expect { provider.destroy }.to_not raise_error
      end
    end
  end
end
