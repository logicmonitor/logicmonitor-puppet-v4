node 'puppet.localdomain' {
  class { 'logicmonitor' :
    account  => 'lmsdacanay',
    user     => 'puppetadmin',
    password => 'marionette'
  }
  include 'logicmonitor::master'
  include 'logicmonitor::collector'
  class { 'logicmonitor::device_group' :
      full_path        => 'puppet',
      description      => 'group description',
      disable_alerting => true,
      properties       => {'testproperty' => 'value'},
  }
  class { 'logicmonitor::device' :
    hostname         => '192.168.0.1',
    display_name     => 'node1',
    description      => 'Sample LM Device',
    properties       => {
      'propertyname'   => 'value',
      'propertyvalue2' => 'value2'
    },
    groups           => ['puppet'],
    disable_alerting => false,
  }
}