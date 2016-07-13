# == Class: logicmonitor::device_group
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

class logicmonitor::device_group (
  $full_path        = '/',
  $description      = '',
  $disable_alerting = false,
  $properties       = {}
) inherits logicmonitor {
  # Validation
  validate_string($full_path)
  validate_string($description)
  validate_bool($disable_alerting)
  validate_hash($properties)

  # Create Resource
  @@device_group { $full_path:
    ensure            => present,
    description       => $description,
    disable_alerting  => $disable_alerting,
    properties        => $properties,
  }
}