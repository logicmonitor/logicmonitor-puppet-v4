# === Class: logicmonitor::config
#
# Sets the account, user, and password
# credentials for your LogicMonitor account
#
# === Parameters
#
#   No parameters
#
# === Variables
#
# [account]
#    The name of your LogicMonitor account.
#    E.g. companyname.logicmonitor.com's account should be "companyname"
#
# [user]
#    A username with adaquate credentials to create,
#    modify, and delete hosts, host groups, and collectors
#    We recommend creating a puppet only user to track changes
#    made by Puppet in the audit log.
#
# [password]
#    The password associated with the chose LogicMonitor user.
#
#
# === Examples
#
# This class is for setting configuration information.
# Does not need to be explicitly included.
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

class logicmonitor::config{

  #LogicMonitor API access credentials
  $account  = 'chimpco'
  $user     = 'bruce.wayne'
  $password = 'nanananananananaBatman!'
}
