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

require_relative 'transport'
require_relative 'tools'
require_relative 'scan_error'

module Firebind

  # Send and receive echo using UDP transport.
  class UdpTransport < Transport
    include Tools
    def initialize (echo_server,timeout)
      super(echo_server,timeout)
    end

    def connect(port)
      @port = port
      begin
        @socket = Socket.new(:INET,:DGRAM)
        @remote_addr = Socket.pack_sockaddr_in(@port, @echo_server)
        @socket.connect_nonblock @remote_addr
      rescue
        raise Firebind::ScanError.new :FAILURE_ON_PAYLOAD_SEND
      end
    end

    # Send data to the echo server, we'll send multiple copies of the same data. So long as the echo server
    # receives one of these we should expect an echo response.
    #
    # @param [Array[]] payload - array of bytes
    def send(payload,num_payloads = 10)
      @payload = payload
      size = payload.length
      count = 0
      send_start = Time.now

      # send the payload this many times
      payloads_sent = 0

      debug "sending buffer #{payload.to_s}"
      #payload.each do |byte|
      while count < size && Time.now - send_start < @timeout_seconds
        begin

          # chomp up the payload depending upon where we left off
          send_buffer = payload[count,size-count]

          count += @socket.write_nonblock send_buffer.pack('C*')
          debug "wrote #{count} bytes to #{@echo_server}:#{@port}"

          if payloads_sent < num_payloads and count == size
            # reset counters to send another payload
            debug "sending datagram number #{payloads_sent}"
            count = 0
            payloads_sent += 1
          end

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

    #
    # Receive echo response from server. Partway through the timeout we'll call send() again to send
    # more datagrams as a last ditch effort to get data across.
    #
    # PAYLOAD_REFUSED_ON_RECV
    # PAYLOAD_ERROR_ON_RECV
    # PAYLOAD_TIMED_OUT_ON_RECV
    #
    def receive
      size = @payload.length
      count = 0
      receive_start = Time.now
      receive_buffer = ''
      halfway = @timeout_seconds/2

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
            # send some more datagrams?
            if Time.now - receive_start > halfway
              begin
                debug "halfway through timeout sending more datagrams on port #{@port}"
                send(@payload,5)
              rescue
                debug "mid-receive cycle resend resulted in #{$!} ignoring"
              end
            end

            # keep going
            IO.select([@socket],nil,nil,halfway)
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
