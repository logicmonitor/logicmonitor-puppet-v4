require_relative '../../spec_helper'

collector_type = Puppet::Type.type(:collector)

describe collector_type do
  let :params do
    [:description, :osfam, :account, :access_id, :access_key]
  end

  it 'has the expected parameters' do
    expect(collector_type.parameters).to be_an_instance_of(Array)
    params.each do |param|
      expect(collector_type.parameters).to include(param)
    end
  end
end
