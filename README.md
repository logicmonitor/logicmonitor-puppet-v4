#LogicMonitor-Puppet-v4

LogicMonitor is a Cloud-based, full stack, IT infrastructure monitoring solution that
allows you to manage your infrastructure monitoring from the Cloud.
LogicMonitor-Puppet-v4 is a Puppet module for automating and managing your LogicMonitor
(SaaS based, full stack, datacenter monitoring) portal via Puppet, specifically for version 4.

##LogicMonitor's Puppet module overview
LogicMonitor's Puppet module defines 5 classes and 4 custom resource types. For additional documentation visit 
<insert Help Documentation URL>

Classes:
* logicmonitor: Handles setting credentials needed for interacting with the LogicMonitor API.
* logicmonitor::master: Collects the exported lm_host resources and lm_hostgroup resources. Communicates with the LogicMonitor API
* logicmonitor::collector: Handles LogicMonitor collector management for the device. Declares an instance of lm_collector and lm_installer resources.
* logicmonitor::device: Declares an exported lm_device resource.
* logicmonitor::device_group: Declares an export lm_device_group resource. 

Resource Types:
* lm_device_group: Defines the behavior of the handling of LogicMonitor device groups. Recommend using exported resources.
* lm_device: Defines the handling behavior of LogicMonitor devices. Used only within logicmonitor::device class.
* lm_collector: Defines the handling behavior of LogicMonitor collectors. Used only with logicmonitor::collector class.
* lm_installer: Defines the handling behavior of LogicMonitor collector installation binaries. Used only within logicmonitor::collector class.

So far, we've implemented the following features:

* Collector Management
* Device Management
  * Ensurable (present/absent)
  * Managed parameters:
    * Display name
    * Description
    * Collector
    * Disable Alerting
    * Group membership
      * Creation of groups/paths which do not yet exist
    * Properties
* Device Group Management
  * Ensurable (present/absent)
  * Managed parameters:
    * Display name
    * Description
    * Collector
    * Disable Alerting
    * Creation of parent groups/paths which do not yet exist
    * Properties

Upcoming features:

* User management
  * Add and remove users
  * Assign user roles

## Requirements

** Ruby (1.9.3, 2.0.X, 2.1.X) and Puppet 3.X OR 4.X **

This is a module written for Puppet 4

** Ruby Gems  JSON Gem **

This module interacts with LogicMonitor's API which is JSON based. 
The JSON gem needed to parse responses from the LogicMonitor API. 
Our Gemfile enforces json ruby gem version 1.7.7, which may be installed 
via
```
$ bundle install
```

** storeconfigs **

This module uses exported resources extensively. Exported resources require storeconfigs = true.

## Installation

### Using the Module Tool

    $ puppet module install logicmonitor-logicmonitor

### Installing via GitHub

    $ cd /etc/puppet/modules
    $ git clone git://github.com/logicmonitor/logicmonitor-puppet-v4.git
    $ mv logicmonitor-puppet-v4 logicmonitor

## Usage

Add a LogicMonitor class with your LogicMonitor account information

    class { 'logicmonitor':
            account    => 'puppettest',
            access_id  => 'XXX',
            access_key => 'XXX',
    }

### Logicmonitor::Master Node

The LogicMonitor module uses the the "logicmonitor::master" class as trigger
to decide which device in your infrastructure will be used to modify your
LogicMonitor account via API calls.  This device must be able to communicate via
SSL with your LogicMonitor account.


    node "puppet-master.lax6.chimpco" {
      # the puppet master is where API calls to the LogicMonitor server are sent from
      include logicmonitor::master

      # In this example, the master will also have a collector installed.  This is optional - the
      # collector can be installed anywhere.
      # NOTE:  this collector will be identied by the facter derived FQDN, eg
      # "puppet-master.lax6.chimpco" in this case.
      include logicmonitor::collector

      # Define default properties and some device groups
      #
      # Managing the properties on the root device group ("/") will set the properties for the entire
      # LogicMonitor account.  These properties can be over-written by setting them on a child
      # group, or on an individual device.
      class { 'logicmonitor::device_group' :
        full_path  => "/",
        properties => {
          "snmp.community"  => "public",
          "tomcat.jmxports" => "9000",
          "mysql.user"      => "monitoring",
          "mysql.pass"      => "MyMysqlPW"
        },
      }

      # create "Development" and "Operations" device groups
      class { 'logicmonitor::device_group' : 
        full_path  => "/Development",
        description => 'This is the top level puppet managed device group',
      }

      class { 'logicmonitor::device_group' : 
        full_path  => "/Operations",
      }

      # Create US-West device group, as well as a sub-group "production".
      # The "production" group will have use a different SNMP community
      class { 'logicmonitor::device_group' : 
        full_path => "/US-West"
      }
      class { 'logicmonitor::device_group' : 
        full_path  => "/US-West/production",
        properties => { "snmp.community"=>"secret_community_RO" },
      }

      class { 'logicmonitor::device_group' : 
        full_path => "/US-East"
      }

      # Your puppet master node should be monitored too of course!  Add it in,
      # place it in two device groups, and set device specific custom properties
      # that you might use for a custom datasource
      class {'logicmonitor::device':
        collector => "puppet-master.lax6.chimpco",
        groups => ["/Operations", "/US-West"],
        properties => {"test.prop" => "test2", "test.port" => 12345 },
      }
    }

### Add all appX.lax6 nodes into monitoring

    node /^app\d+.lax6/ {
      $lm_collector = "puppet-master.lax6.chimpco"

      class {'logicmonitor::device':
        collector => $lm_collector,
        groups => ["/US-West/production"],
        properties => {"jmx.pass" => "MonitorMEEEE_pw_", "jmx.port" => 12345 },
      }
    }

### Additional collector and East Coast nodes

    # Install a collector on a dedicated machine for monitoring the East Coast
    # data center
    node "collector1.dc7.chimpco" {

      # install a collector on this machine.  It is identified
      # by the facter derived fqdn
      include logicmonitor::collector

      # and add it into monitoring
      class {'logicmonitor::device':
        collector  => "collector1.dc7.chimpco",
        groups     => ["/US-East","Operations"]
      }
    }

    # All East coast nodes will be monitored by the previously defined collector
    node /^app\d+.dc7/ {
      class {"logicmonitor::device":
        collector => "collector1.dc7.chimpco",
        groups => ["/US-East"],
      }
    }

