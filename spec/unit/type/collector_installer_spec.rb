require_relative '../../spec_helper'

collector_installer_type = Puppet::Type.type(:collector_installer)

describe collector_installer_type do
  let :params do
    [ :description, :install_dir, :architecture, :account, :access_id, :access_key ]
  end

  it 'should have the expected parameters' do
    expect(collector_installer_type.parameters).to be_an_instance_of(Array)
    params.each do |param|
      expect(collector_installer_type.parameters).to include(param)
    end
  end
end