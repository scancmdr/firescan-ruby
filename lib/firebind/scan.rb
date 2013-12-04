# Firebind -- Path Scan Client Software
# Copyright (C) 2013 Firebind Inc. All rights reserved.
# Authors - Jay Houghton
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require 'net/http'
require 'uri'
require 'json'
require 'observer'
require_relative 'simple_protocol'
require_relative 'portspec'
require_relative 'tools'
require_relative 'scan_state'

# This module encapsulates client-side path scanning functionality for use with an associated Firebind server.
module Firebind


  # This is the primary API object for performing scans. Simply supply the necessary arguments to create a Scan
  # and call the scan() method
  #--
  #noinspection RubyTooManyInstanceVariablesInspection
  class Scan
    include Observable
    include Tools

    # Create a new Scan
    #
    #--
    # @param [Object] command_server
    # @param [Object] ports
    def initialize (command_server, ports, transport, timeout=5000, protocol=:SimpleProtocol, username=nil, password=nil)
      @command_server = command_server
      @portspec = Firebind::Portspec.new(ports)
      @timeout = timeout
      @protocol = protocol
      @username = username
      @password = password
      @transport = transport
      @done = false
      @state = ScanState.new(command_server,protocol,transport,@portspec,timeout)


    end

    # Perform the path scan
    #
    # :call-seq:
    #   scan  -> ScanState
    #
    def scan

      api_start
      changed
      notify_observers(@state)

      if @done
        return @state
      end

      case @protocol
        when :SimpleProtocol
          scan_protocol = SimpleProtocol.new(@state.guid,@state.echo_server,@state.transport,@timeout)

        else
          scan_protocol = SimpleProtocol.new(@state.guid,@state.echo_server,@state.transport,@timeout)
      end


      @portspec.ports.each do |port|
        break if @done
        begin

          if @state.ports_scanned > 0
            # make sure we don't fry the routers
            debug("waiting #{@state.port_delay_seconds}s for next port echo")
            IO.select(nil,nil,nil,@state.port_delay_seconds)
          end

          # callback for port start
          @state.on_port_start(port)
          changed
          notify_observers(@state)

          # perform the path echo send/receive
          scan_protocol.echo(port)
          port_result_code = $result_codes[:SUCCESS]

        rescue Firebind::ScanError => error
          debug "error on port #{port} #{error.to_s}"
          case error.status_code
            when :HANDSHAKE_CONNECTION_TIME_OUT,
                 :HANDSHAKE_CONNECTION_INITIATION_FAILURE,
                 :HANDSHAKE_CONNECTION_REFUSED,
                 :HANDSHAKE_CONNECTION_COMPLETION_FAILURE,
                 :PAYLOAD_REFUSED_ON_RECV,
                 :PAYLOAD_TIMED_OUT_ON_RECV,
                 :PAYLOAD_ERROR_ON_RECV,
                 :PAYLOAD_MISMATCH_ON_RECV,
                 :FAILURE_ON_PAYLOAD_SEND

              # try skipping
              port_result_code = $result_codes[error.status_code]
              if api_skip port

              else

              end

            else  # status_code is not skippable
              @state.on_error(error.status_code)
              changed
              notify_observers(@state)
              raise error


          end

        ensure
          # callback for port complete - success/open
          @state.on_port_complete(port,port_result_code)
          changed
          notify_observers(@state)
        end

      end

      api_update

      if @portspec.size == @state.ports_scanned
        @state.on_scan_complete($client_scan_completed)
        changed
        notify_observers(@state)
      end

      #update
      @state
    end

    def stop
      puts 'setting flags'
      @stop_requested = true
      @done = true
      api_stop
      api_update
    end

    private

    # perform an Identify API call to the server, for authentication testing
    def api_identify
      uri = URI.parse("http://#{@command_server}/api/user")
      http = Net::HTTP.new(uri.host, uri.port)        # create http client
      request = Net::HTTP::Head.new(uri.request_uri)  # create request object
      request.basic_auth(@username, @password)

      begin
        response = http.request(request)
      rescue
        debug "Identify API call failed #{$!}"
        return false
      end

      '1001' == response['status']
    end

    # perform a Scan API call to the server to initiate a path scan sequence
    def api_start
      uri = URI.parse("http://#{@command_server}/api/scan")
      http = Net::HTTP.new(uri.host, uri.port)        # create http client
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(@username, @password)

      transport_proto = if @transport == :UDP then 'udp' else 'tcp' end

      data = {portSpec:@portspec.to_s,protocol:transport_proto}
      request.body = data.to_json

      #noinspection RubyStringKeysInHashInspection
      #request.set_form_data({'portSpec' => @portspec.to_s, 'protocol' => 'TCP'})

      begin
        response = http.request(request)
      rescue # can't connect
        @state.on_start_failure($command_server_unavailable)
        @state.message = @command_server
        @done = true
        return
      end

      result = JSON.parse response.body
      if 2000 == result['status']
        # we're ok to go
        @state.on_scan_start(result['guid'],result['echoHost'],result['portDelay'])
      else
        @state.on_start_failure(result['status'])
        @done = true
        #raise ('scan request failed with status '+result['status'].to_s)
      end

      true
    end

    # perform a Skip API call to the server
    def api_skip(port)
      begin
        uri = URI.parse("http://#{@command_server}/api/scan/#{@state.echo_server}/#{@state.guid.to_s}/#{port.to_s}")
        http = Net::HTTP.new(uri.host, uri.port) # create http client
        request = Net::HTTP::Patch.new(uri.request_uri)
        request.basic_auth(@username, @password)
        verbose "skipping port #{port}"
        response = http.request(request)
        if '5000' == response['status']
          debug "successful skip for port #{port}"
          true
        else
          debug "unsuccessful skip for port #{port} response was #{response['status']}"
          false
        end
      rescue
        debug "Skip API call failed with #{$!}"
        false
      end
    end

    # perform a Stop API call to the server
    def api_stop
      uri = URI.parse("http://#{@command_server}/api/scan/#{@state.echo_server}/#{@state.guid.to_s}")
      debug "stopping scan with #{uri}"
      http = Net::HTTP.new(uri.host, uri.port)        # create http client
      request = Net::HTTP::Delete.new(uri.request_uri)
      request.basic_auth(@username, @password)
      begin
        response = http.request(request)
      rescue
        debug "Stop API call failed #{$!}"
        return false
      end
      @state.on_scan_stop
      '9000' == response['status']
    end

    # perform an Update API call to the server
    def api_update
      uri = URI.parse("http://#{@command_server}/api/scan/#{@state.echo_server}/#{@state.guid.to_s}")
      http = Net::HTTP.new(uri.host, uri.port)        # create http client
      request = Net::HTTP::Put.new(uri.request_uri)
      request.basic_auth(@username, @password)

      data = Array.new
      @state.result_map.each do |code,ports|
         ps = Portspec.new(ports)
         status = if code == $success then 'Passed' else 'Failed' end
        data << { guid:@state.guid, serverId:@state.echo_server, portSpec:ps.to_s, statusCode:code, status:status}
      end

      test_status = if @state.current_state == :SCAN_COMPLETE then 'Success' else 'Failed' end

      #build json payload with results
      report = { clientReport: { guid:@state.guid, serverId:@state.echo_server, testStatus:test_status, uid:@username},
                 clientReportData: data }
      #jj report
      json = report.to_json
      request.body = json

      begin
        response = http.request(request)
      rescue
        debug "Update API call failed #{$!}"
        return false
      end

      '9000' == response['status']
    end

  end
end
