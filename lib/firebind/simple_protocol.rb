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

require_relative 'tcp_transport'
require_relative 'udp_transport'
require_relative 'tools'

module Firebind

  # Simplest of all echo protocols. This simply sends and receives an 8-byte payload representing the
  # ID number of the scan that was assigned during the Scan API call.
  class SimpleProtocol

    include Tools

    # @param [Object] transport
    def initialize(guid,echo_host,transport,timeout,state=NIL)
      @guid = guid
      @echo_host = echo_host
      @state = state
      case transport
        when :TCP
          @transport = Firebind::TcpTransport.new @echo_host,timeout
        when :UDP
          @transport = Firebind::UdpTransport.new @echo_host,timeout
        else
          @transport = Firebind::TcpTransport.new @echo_host,timeout
      end
    end

    def echo(port)
      payload = big_endian @guid
      begin
        @transport.connect port  # connect
      end

      begin
        @transport.send payload  # send
        @transport.receive       # receive
      ensure
        @transport.close         # close
      end
    end

  end
end
