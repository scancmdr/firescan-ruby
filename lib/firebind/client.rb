#--
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
#++

require 'optparse'
require 'ostruct'
require 'date'

require_relative 'scan'
require_relative 'tools'

module Firebind

  # Firescan command line Ruby client for path scanning to a Firebind server
  class Client
    include Tools
    VERSION = '0.07'

    attr_reader :options

    def initialize(arguments)
      @arguments = arguments

      @opts = nil
      # Set defaults
      @options = OpenStruct.new
      @options.username = nil
      @options.password = nil
      @options.command_server = 'scanme.firebind.com'
      @options.protocol = :Simple
      @options.transport = :TCP
      @options.timeout = 5000
      @options.tcp_port_list = nil
      @options.udp_port_list = nil
      @options.local_address = nil
      @options.tag = nil
    end

    # Parse options, check arguments, then process the command
    def run
      scan = nil
      begin

        if parsed_options? && arguments_valid?
          puts
          verbose "Start at #{DateTime.now}"
          puts "Firescan Ruby client version #{VERSION} ( http://www.firebind.com )"
          #############
          # TCP scan
          #############
          unless @options.tcp_port_list.nil?

            debug "performing scan on TCP #{@options.tcp_port_list} via #{@options.command_server}"

            scan = Scan.new(@options.command_server,
                            @options.tcp_port_list,
                            :TCP,
                            @options.timeout,
                            :SimpleProtocol,
                            @options.username,
                            @options.password,
                            @options.tag)

            scan.add_observer self
            begin
              @tcp_scan = scan.scan

              debug "scan state: #{@tcp_scan.to_s}"
            rescue Errno::EHOSTUNREACH
              puts 'host not reachable'
            end
          end

          #############
          # UDP scan
          #############
          unless @options.udp_port_list.nil?

            debug "performing scan on UDP #{@options.udp_port_list} via #{@options.command_server}"

            scan = Scan.new(@options.command_server,
                            @options.udp_port_list,
                            :UDP,
                            @options.timeout,
                            :SimpleProtocol,
                            @options.username,
                            @options.password,
                            @options.tag)

            scan.add_observer self
            puts
            begin
              @udp_scan = scan.scan

              debug "scan state: #{@udp_scan.to_s}"
            rescue Errno::EHOSTUNREACH
              puts 'host not reachable'
            end
          end

          do_output
          verbose "Finished at #{DateTime.now}"

        else
          puts @opts
        end
      rescue Interrupt
        puts 'Stopping scan'
        scan.stop
      end
    end


    # command line output formatting helpers
    def do_scan_output(state)
      open_ports = state.open_ports
      closed_ports = state.closed_ports

      open_defa = if open_ports.size>1 then 'are' else 'is' end
      closed_defa = if closed_ports.size>1 then 'are' else 'is' end

      port_or_ports = if state.ports_scanned == 1 then 'port' else 'ports' end

      transport_output = ''
      transport_output << "#{state.transport} Port#{'s' unless open_ports.size == 1} #{open_ports.to_s} " \
            "#{open_defa} open\n" unless open_ports.size == 0
      transport_output << "#{state.transport} Port#{'s' unless closed_ports.size == 1} #{closed_ports.to_s} " \
            "#{closed_defa} closed\n" unless closed_ports.size == 0

      scanned_output = ''
      scanned_output << "\nScanned #{state.ports_scanned} #{state.transport} #{port_or_ports}"
      scanned_output << ", #{open_ports.size} #{open_defa} open" unless open_ports.size == 0
      scanned_output << ", #{closed_ports.size} #{closed_defa} closed" unless closed_ports.size == 0

      port_detail_output = ''
      state.result_map.each do |code,ports|
        unless code == $success
          ps = Portspec.new(ports)
          port_detail_output << "#{port_or_ports.capitalize} #{ps.to_s} #{if ps.size>1 then 'are' else 'is' end} closed - #{$result_code_messages[code]}\n"
        end
      end

      return transport_output,scanned_output,port_detail_output
    end

    def do_output

      tcp = @tcp_scan && @tcp_scan.current_state == :SCAN_COMPLETE
      udp = @udp_scan && @udp_scan.current_state == :SCAN_COMPLETE

      # we had a complete scan, show summary

      out = "\n"
      if tcp
        out << "Completed #{@tcp_scan.protocol} scan of #{@tcp_scan.transport} #{@tcp_scan.portspec.to_s}\n"
        tcp_transport_out,tcp_scanned_out,tcp_port_detail_out = do_scan_output(@tcp_scan)
      end
      if udp
        out << "Completed #{@udp_scan.protocol} scan of #{@udp_scan.transport} #{@udp_scan.portspec.to_s}\n"
        udp_transport_out,udp_scanned_out,udp_port_detail_out = do_scan_output(@udp_scan)
      end

      out << tcp_transport_out if tcp_transport_out
      out << udp_transport_out if udp_transport_out

      out << tcp_scanned_out if tcp_scanned_out
      out << udp_scanned_out if udp_scanned_out
      out << "\n"

      out << tcp_port_detail_out if tcp_port_detail_out
      out << udp_port_detail_out if udp_port_detail_out

      puts out

    end

    # scan callback interface
    # @param [Object] state
    def update(state)
      debug "callback #{state.to_s}"

      case state.current_state
        when :PORT_COMPLETE

          if state.port_result_code == $success
            puts " open in #{state.port_duration}ms #{state.percent_complete}%"
          else
            puts " closed after #{state.port_duration}ms - #{$result_code_messages[state.port_result_code]}"
          end

          $stdout.flush
        when :PORT_START
          print "#{state.transport.to_s} #{state.port.to_s}"
        when :PORT_TICK
          print '.'
        when :SCAN_START
          puts "Performing #{state.protocol} scan on #{state.transport} ports #{state.portspec.to_s} via #{state.command_server} with #{state.timeout}ms timeout"
        when :START_FAILURE
          case state.status_code
            when $authentication_failure
              puts 'Authentication failure'
            when $request_invalid
              puts 'Incompatible command server (request invalid)'
            when $server_bind_error
              puts "Server unable to bind on ports #{state.portspec.to_s}"
            when $command_server_unavailable
              puts "Unable to reach command server #{state.message}"
            else
              puts "Unable to start scan (code #{state.status_code})"
          end
        when :SCAN_COMPLETE

        else
          puts "unhandled callback #{state.to_s}"
      end

    end

    protected

    # figure what arguments we have to work with
    def parsed_options?

      @opts = OptionParser.new do |opt|
        opt.banner = "\nFirescan Ruby client version #{VERSION} ( http://www.firebind.com )\nUsage: firescan [options] "
        opt.separator ''
        opt.separator 'Options'

        opt.on('-h', '--help','Show help and version') do
          puts @opts
          exit
        end
        opt.on('-v', '--verbose','Show verbose output') do
          $verbose = true
        end
        opt.on('-s ADDRESS', '--command-server ADDRESS','Address:port or hostname:port of command server, default port is 80',String) do |address|
          @options.command_server = address
        end
        opt.on('-t PORT_LIST', '--tcp PORT_LIST','TCP Port specification (list), use commas and dashes to specify a list of ports',String) do |tcp_port_list|
          @options.tcp_port_list = tcp_port_list
        end
        opt.on('-u PORT_LIST', '--udp PORT_LIST','UDP Port specification (list), use commas and dashes to specify a list of ports',String) do |udp_port_list|
          @options.udp_port_list = udp_port_list
        end
        opt.on('-i TIMEOUT', '--timeout TIMEOUT','Timeout (in milliseconds) to use for connect, transmit and receive operations',Integer) do |timeout|
          @options.timeout = timeout
        end
        opt.on('-n USERNAME', '--username USERNAME','Specify a username (to connect to command server)',String) do |username|
          @options.username = username
        end
        opt.on('-p PASSWORD', '--password PASSWORD','Specify a password (to connect to command server)',String) do |password|
          @options.password = password
        end
        #opt.on('-r PROTOCOL', '--protocol PROTOCOL','Specify a protocol (defaults to Simple protocol)',String) do |protocol|
          #@options.protocol = protocol
          # todo handle this when IMG is available
        #end
        opt.on('-g TAG', '--tag TAG','tag the scan with value',String) do |tag|
          @options.tag = tag
        end
        #opt.on('-l LOCAL_ADDRESS', '--localaddr LOCAL_ADDRESS','Specify local IP address for client binding',String) do |addr|
        #  @options.local_address = addr
        #end
        opt.on('-d', '--xdebug','Show debug output') do
          $verbose = true
          $debug = true
        end
        opt.separator ''
     end

      @opts.parse!(@arguments) rescue return false

      verbose 'verbose output is on'
      debug 'debug output is on'

      if $debug
        output_options
      end
      #debug @options.to_s

      true
    end

    def output_options
      puts "Options:\           "
      @options.marshal_dump.each do |name, val|
      puts "  #{name} = #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
      true if @options.udp_port_list != nil || @options.tcp_port_list != nil
    end

  end

end
