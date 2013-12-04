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

require_relative 'tools'
module Firebind

  #
  # Scan lifecycle states
  #  SCAN_SETUP
  #  SCAN_START
  #  PORT_START
  #  PORT_TICK
  #  PORT_COMPLETE
  #   ...
  #  SCAN_STOP or SCAN_COMPLETE  or START_FAILURE or ERROR
  #
  #noinspection RubyTooManyInstanceVariablesInspection
  class ScanState
    include Tools

    attr_reader :current_state, :guid, :echo_server, :protocol, :transport, :portspec, :port, :port_delay, :status_code,
                :port_result_code, :ports_scanned, :last_duration, :result_map, :command_server, :timeout
    attr_accessor :message

    # @param [Firebind::Portspec] portspec
    def initialize(command_server,protocol,transport,portspec,timeout)
      @command_server = command_server
      @current_state = :SCAN_SETUP
      @protocol = protocol
      @transport = transport
      @portspec = portspec
      @timeout = timeout
      @guid = nil
      @echo_server = nil
      @port = 0
      @last_duration = 0
      @ports_scanned = 0
      @result_map = Hash.new {|hash,key| hash[key]=[]}  # block form
      @message = nil
    end

    def to_s
      "#{@current_state.to_s} port #{@port} results #{@result_map}"
    end

    # lifecycle methods
    def on_scan_start(guid,echo_server,port_delay)
      @current_state = :SCAN_START
      @guid = guid
      @echo_server = echo_server
      @port_delay = port_delay
    end

    def on_start_failure(status_code)
      @current_state = :START_FAILURE
      @status_code = status_code
    end

    def on_port_start(port)
      @current_state = :PORT_START
      @port = port
      @port_start_time = Time.now
    end

    def on_port_tick
      @current_state = :PORT_TICK
    end

    # @param [Object] port
    def on_port_complete(port,port_result_code)
      @port_end_time = Time.now
      @current_state = :PORT_COMPLETE
      @port = port
      @port_result_code =  port_result_code
      @ports_scanned += 1
      @result_map[port_result_code] <<  port
    end

    def on_scan_complete(status_code)
      @current_state = :SCAN_COMPLETE
      @status_code = status_code
    end

    def on_scan_stop
      @current_state = :SCAN_STOPPED
    end

    def on_error(status_code)
      @current_state = :ERROR
      @status_code = status_code
    end

    # data methods
    def port_duration
      (((@port_end_time - @port_start_time) * 1000)+0.5).to_i
    end

    def percent_complete
      ((@ports_scanned.to_f / @portspec.size.to_f) * 100).to_i
    end

    # return a Portspec of the open ports for this scan
    def open_ports
      Portspec.new(@result_map[$success])
    end

    # return a Portspec of the closed ports for this scan
    def closed_ports
      closed = Array.new
      @result_map.each do |code,ports|
        closed += ports unless code == $success
      end
      Portspec.new(closed)
    end

    def port_delay_seconds
      @port_delay.to_f / 1000
    end

    def description(port_result_code)
      $result_code_messages[port_result_code]
    end

  end

end

