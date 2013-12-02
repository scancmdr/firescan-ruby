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

module Firebind

  # This data structure encapsulates the properties and operations of a port list. Arbitrary lists of comma separated
  # and dashed-ranges can be converted into a full array of ports for a list.
  # This class will eventually require the full complement of set arithmetic
  class Portspec

    attr_reader :ports, :compiled_list

    # Supply either a string or int array
    # examples: 1,2,3,55,10-20 or [56,34,443,25,6000]
    def initialize(port_list)

      port_map = Hash.new
      if port_list.kind_of?(Array)  # numeric array, possible dups and out of range values
        port_list.each do |port|
          port_map[port] = port
        end

      elsif port_list.kind_of?(String)  # comma and dash port list, possible dups and out of range values
        #validate
        if port_list !~ /^[0-9,\-]+$/
          raise ArgumentError, 'Bad port specification '+port_list, caller
        end
        port_list.split(/\s*,\s*/).each do |part|
          if part =~  /[\-]+/  # is this a range?
            first,last = part.split(/\-/)
            #noinspection RubyForLoopInspection
            for port in first.gsub(/[^0-9]/,'').to_i..last.gsub(/[^0-9]/,'').to_i
              port_map[port] = port
            end
          else
            port = part.gsub(/[^0-9]/,'').to_i
            port_map[port] = port
          end
        end
      end

      # sort the map and insert the expanded port list into our @ports array
      @ports = Array.new
      i = 0
      port_map.sort_by {|number,flag|number}.each do |port,flag|
        if port < 1 or port > 65535
          raise ArgumentError, 'Bad port number '+port.to_s, caller
        end
        @ports[i] = port
        i += 1
      end

      # generate a compiled port specification based on the ordered list in array
      last_port = -1
      building_a_range = false
      @compiled_list = ''
      @ports.each_with_index do |port,index|
        if port == (last_port+1)
          # continue building range
          building_a_range = true
          # are we at the end of the array? if so we're not coming back here...
          if index == @ports.length-1
            @compiled_list += '-' + port.to_s
          end
        else
          if building_a_range
            # end of the range
            @compiled_list += '-' + last_port.to_s + ',' + port.to_s
            building_a_range = false
          else
            @compiled_list += ',' unless @compiled_list.length == 0
            @compiled_list += port.to_s
          end
        end
        last_port = port
      end
    end

    def to_s
       @compiled_list
    end

    def size
      @ports.length
    end

  end

  #ports = '6,5,4445,4,3,2,50-60,666,69,55,65534,65533'
  #ps = Firebind::Portspec.new(ports)
  #puts ports + " ==> " + ps.to_s

end

