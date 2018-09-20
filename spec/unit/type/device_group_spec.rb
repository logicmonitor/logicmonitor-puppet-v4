require_relative '../../spec_helper'

device_group_type = Puppet::Type.type(:device_group)

describe device_group_type do
  let :params do
    [:full_path, :account, :access_id, :access_key]
  end

  let :properties do
    [:description, :disable_alerting, :properties]
  end

  it 'has the expected parameters' do
    expect(device_group_type.parameters).to be_an_instance_of(Array)
    params.each do |param|
      expect(device_group_type.parameters).to include(param)
    end
  end

  it 'has the expected properties' do
    expect(device_group_type.properties).to be_an_instance_of(Array)
    properties.each do |property|
      expect(device_group_type.properties.map(&:name)).to include(property)
    end
  end
end
