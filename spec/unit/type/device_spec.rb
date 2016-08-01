require_relative '../../spec_helper'

device_type = Puppet::Type.type(:device)

describe device_type do
  let :params do
    [ :hostname, :account, :access_id, :access_key, :user, :password ]
  end

  let :properties do
    [:display_name, :description, :disable_alerting, :groups, :properties]
  end

  it 'should have the expected parameters' do
    expect(device_type.parameters).to be_an_instance_of(Array)
    params.each do |param|
      expect(device_type.parameters).to include(param)
    end
  end

  it 'should have the expected properties' do
    expect(device_type.properties).to be_an_instance_of(Array)
    properties.each do |property|
      expect(device_type.properties.map(&:name)).to include(property)
    end
  end
end