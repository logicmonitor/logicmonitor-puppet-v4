# collector.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

require 'json'

Puppet::Type.type(:collector).provide(:collector, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the creation, status, and deletion of collectors'

  # Creates a Collector
  def create
    debug "Creating Collector \"#{resource[:description]}\""
    create_collector = rest(nil, COLLECTOR_ENDPOINT, HTTP_POST, nil, build_collector_json(resource[:description]))
    valid_api_response?(create_collector) ? debug create_collector : alert create_collector
  end

  # Deletes a Collector
  def destroy
    debug "Deleting Collector \"#{resource[:description]}\""
    collector = rest(nil,
                     COLLECTORS_ENDPOINT,
                     HTTP_GET,
                     build_query_params("description:#{resource[:description]}", 'id', 1))
    if valid_api_response?(collector, true)
      debug "Found Collector: #{collector}"
      delete_collector = JSON.parse(rest("setting/collectors/#{collector['data']['items'][0]['id']}", HTTP_DELETE))
      valid_api_response?(delete_collector, false, true) ? debug delete_collector : alert delete_collector
    else
      alert collector
    end
  end

  # Checks if Collector exists
  def exists?
    collectors = rest(nil,
                      COLLECTORS_ENDPOINT,
                      HTTP_GET,
                      build_query_params("description:#{resource[:description]}", 'id', 1))
    if valid_api_response?(collectors, true)
      debug "Found Collector: #{collectors}"
      return true
    else
      alert collectors
    end
    false
  end

  # Builds JSON required to create a Collector
  # description: description of collector
  def build_collector_json(description)
    collector_hash = Hash.new
    collector_hash['description'] = description

    # The Rest of the fields are default values.
    # This can be modified to include customer entered values, but then need to implement update functionality
    collector_hash['backupAgentId'] = 0
    collector_hash['enableFailBack'] = true
    collector_hash['resendIval'] = 15
    collector_hash['suppressAlertClear'] = false
    collector_hash['escalatingChainId'] = 0
    collector_hash['collectorGroupId'] = 1

    collector_hash.to
  end
end