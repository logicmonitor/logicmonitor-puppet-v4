# === Class: Logicmonitor
#
# This is the top level class for managing your LogicMonitor portal through Puppet and PuppetDB. It also is the location
# where you specify the required credentials for both your LogicMonitor portal as well as configure access to a running
# PuppetDB.
#
# === Parameters
#
# [*account*]
#    Sets which portal to manage
#
# [*user*]
#    Username for access to the portal. This user must have sufficient permissions to create/modify devices, device
#    groups, and collectors.
#
# [*password*]
#    Password for access to the portal. Note that all parameters can be set when the class is declared in your site.pp
#    (must be declared either globally or on a single node), or in the variables found in logicmonitor::config
#
# === Variables
#
#    None
#
# === Examples
#
# With parameters:
#   class{ "logicmonitor":
#     account             => "mycompany",
#     $user               => "me",
#     $password           => "password",
#   }
#
# Using logicmonitor::config:
#   class( "logicmonitor": }
#
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

class logicmonitor(
  $account=$logicmonitor::config::account,
  $user=$logicmonitor::config::user,
  $password=$logicmonitor::config::password,
) inherits logicmonitor::config {

}
