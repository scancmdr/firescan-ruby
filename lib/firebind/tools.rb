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

# Utility module for translating socket and result codes.
module Tools

  $debug = false
  $verbose = false

  def big_endian(a_number)
    bytes = []
    7.downto(0) do |i|
      bytes[i] = 0xFF & a_number
      a_number = a_number >> 8
    end
    bytes
  end

  # @@SOCKET_CODES = { :CONNECTION_REFUSED => }

  #
  # Result Codes as defined in reference documents
  # http://www.firebind.com/support/reference/socket_mapping.html
  #
  $handshake_connection_refused = 12152
  $handshake_connection_timeout = 12151
  #noinspection RubyGlobalVariableNamingConvention
  $handshake_connection_initiation_failure = 12150
  $payload_refused_on_recv = 12156
  $payload_timed_out_on_recv = 12155
  $payload_error_on_recv = 12158
  $payload_mismatch_on_recv = 12157
  $failure_on_payload_send = 12154
  #noinspection RubyGlobalVariableNamingConvention
  $handshake_connection_completion_failure = 12153
  $success = 12110
  $skipped = 12020
  $scan_failure = 12111
  $client_network_failure = 12112
  $command_server_unavailable = 7

  $result_codes = {HANDSHAKE_CONNECTION_REFUSED: $handshake_connection_refused,
                  HANDSHAKE_CONNECTION_TIME_OUT: $handshake_connection_timeout,
                  HANDSHAKE_CONNECTION_INITIATION_FAILURE: $handshake_connection_initiation_failure,
                  PAYLOAD_REFUSED_ON_RECV: $payload_refused_on_recv,
                  PAYLOAD_TIMED_OUT_ON_RECV: $payload_timed_out_on_recv,
                  PAYLOAD_ERROR_ON_RECV: $payload_error_on_recv,
                  PAYLOAD_MISMATCH_ON_RECV: $payload_mismatch_on_recv,
                  FAILURE_ON_PAYLOAD_SEND: $failure_on_payload_send,
                  HANDSHAKE_CONNECTION_COMPLETION_FAILURE: $handshake_connection_completion_failure,
                  SUCCESS: $success,
                  SKIPPED: $skipped,
                  TEST_FAILURE: $scan_failure,
                  CLIENT_NETWORK_FAILURE: $client_network_failure
  }

  # todo: finish reverse result code / symbol mapping

  #result_code_rev = { $handshake_connection_refused => :HANDSHAKE_CONNECTION_REFUSED }

  $result_code_messages = { $handshake_connection_refused => 'Handshake Connection Refused',
                            $handshake_connection_timeout => 'Handshake Connection Timeout',
                            $handshake_connection_initiation_failure => 'Handshake Connection Initiation Failure',
                            $payload_refused_on_recv => 'Payload Refused On Receive',
                            $payload_timed_out_on_recv => 'Payload Timed Out On Receive',
                            $payload_error_on_recv => 'Payload Error On Receive',
                            $payload_mismatch_on_recv => 'Payload Mismatch On Receive',
                            $failure_on_payload_send => 'Failure On Payload Send',
                            $handshake_connection_completion_failure => 'Handshake Connection Completion Failure',
                            $success => 'Open',
                            $skipped => 'Skipped',
                            $scan_failure => 'Scan Failure',
                            $client_network_failure => 'Client Network Failure'
  }

  # server status codes
  $authentication_failure = 20401
  $request_invalid = 20400
  $server_bind_error = 2017
  $client_scan_completed = 12021

  def verbose(msg)
    puts "Firescan - #{msg}" if $verbose
  end

  def debug(msg)
    puts "DEBUG #{self.class.to_s} - #{msg}"  if $debug
  end

  def out(msg)
    puts msg
  end

end
