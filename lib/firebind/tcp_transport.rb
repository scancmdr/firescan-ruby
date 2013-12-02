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

require_relative 'transport'
require_relative 'tools'
require_relative 'scan_error'

module Firebind

  # Send and receive echo using TCP transport.
  class TcpTransport < Transport
    include Tools
    def initialize (echo_server,timeout)
      super(echo_server,timeout)
    end

    # establish connection to echo server on port
    def connect(port)
      @port = port
      connect_start = Time.now
      #host_addr = Socket.getaddrinfo(@echo_server,nil)  # probably should get 0,3 from this guy for IPv6

      begin
        #noinspection RubyArgCount
        @socket = Socket.new(:INET, :STREAM)
        @remote_addr = Socket.pack_sockaddr_in(@port, @echo_server)
      rescue
        raise Firebind::ScanError.new :HANDSHAKE_CONNECTION_INITIATION_FAILURE
      end

      begin
        @socket.connect_nonblock @remote_addr
      rescue Errno::EINPROGRESS
        # still doing handshake, wait @timeout until its ready to connect_nonblock again
        debug("connection still inprogress select for #{@timeout}ms")

        # interest ops: reading,writing,error,timeout
        readables,writables,errors = IO.select([@socket], [@socket], [@socket], @timeout_seconds)
        debug "readables=#{readables} writables=#{writables} errors=#{errors}"

        readable = readables != NIL && readables.length > 0
        writable = writables != NIL && writables.length > 0
        error = errors != NIL && errors.length > 0

        if error
          raise Firebind::ScanError.new(:HANDSHAKE_CONNECTION_REFUSED)
        end

        if readable || writable
          retry
        else
          debug "connection timeout after #{@timeout}ms"
          raise Firebind::ScanError.new :HANDSHAKE_CONNECTION_TIME_OUT
        end

        # A time check may be required in the future (if we select for less than timeout)
        # if Time.now - connect_start > @timeout_seconds
        #  raise Firebind::ScanError.new :HANDSHAKE_CONNECTION_TIME_OUT

      rescue Errno::EISCONN # this is a linux code... todo: figure the platform codes for continuation
        debug 'connection success'
      rescue Errno::ECONNREFUSED => e
        raise Firebind::ScanError.new(:HANDSHAKE_CONNECTION_REFUSED, e)
      rescue
        #collect all the ways a connection can fail... some of the conditions are:
        #  1) No route to host - connect(2)
        raise Firebind::ScanError.new(:HANDSHAKE_CONNECTION_REFUSED, $!)
      end
    end

    # Send data to the echo server
    #
    # @param [Array[]] payload - array of bytes
    def send(payload)
      @payload = payload
      size = payload.length
      count = 0
      send_start = Time.now

      payload.each do |byte|
        begin
          count += @socket.write_nonblock [byte].pack('C')
          debug "wrote #{count} bytes to #{@echo_server}:#{@port}"
        rescue IO::WaitWritable, Errno::EINTR
          if count == size
            # we've written our payload, we're done
            debug "completed #{count} byte payload to #{@echo_server}:#{@port}"
          elsif Time.now - send_start > @timeout_seconds
            # we've timed out of sending
            raise Firebind::ScanError.new :FAILURE_ON_PAYLOAD_SEND
          else
            # try to write some more ?  http://ruby-doc.org/core-1.9.3/IO.html#method-i-write_nonblock
            retry
          end

        rescue
          #collect all the ways a send can fail...
          raise Firebind::ScanError.new(:FAILURE_ON_PAYLOAD_SEND, $!)
        end

      end
    end

    # Receive echo response from server.
    #
    #
    # PAYLOAD_REFUSED_ON_RECV
    # PAYLOAD_ERROR_ON_RECV
    # PAYLOAD_TIMED_OUT_ON_RECV
    #
    # @return [Object]
    def receive
      size = @payload.length
      count = 0
      receive_start = Time.now
      receive_buffer = ''

      while Time.now - receive_start <= @timeout_seconds && count < size
        begin
          read_result = @socket.read_nonblock(1024)
          count += read_result.length  # because appending to receive_buffer won't count recv bytes via .length
          # add read_result to our buffer
          receive_buffer << read_result
          debug "read buffer is #{count}"
        rescue IO::WaitReadable
          if count == size
            # we're done - read all we had expected to receive
            debug "completed full read of #{count} bytes"
            break
          elsif Time.now - receive_start > @timeout_seconds
            # timeout on receive
            raise Firebind::ScanError.new(:PAYLOAD_TIMED_OUT_ON_RECV)
          else
            # keep going
            IO.select([@socket],nil,nil,@timeout_seconds)
            retry
          end
        rescue EOFError => e
          # connection was forcefully dropped or sent a final FIN ACK closing sequence
          if count != size
            raise Firebind::ScanError.new(:PAYLOAD_ERROR_ON_RECV,e)
          end

        rescue
          #collect all the ways a receive can fail... todo:
          if $debug
            puts 'Caught unhandled socket error:'
            p $1
            puts $@
          end
          raise Firebind::ScanError.new(:PAYLOAD_REFUSED_ON_RECV,$!)
        end
      end

      # we still could have timed out here, check rx buffer size first
      if count < size
        raise Firebind::ScanError.new(:PAYLOAD_TIMED_OUT_ON_RECV)
      end

      # now compare what we received with what we sent
      received_array = receive_buffer.unpack('C*')
      if received_array != @payload
        debug "rx buffer #{received_array.to_s} is NOT equal to expected #{@payload.to_s}"
        raise Firebind::ScanError.new(:PAYLOAD_MISMATCH_ON_RECV)
      else
        debug "rx buffer #{received_array.to_s} is equal to payload #{@payload.to_s}"
      end

    end
  end
end
