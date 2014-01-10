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

module Firebind
  class ScanError < IOError

    attr_reader :status_code

    def initialize(status_code, error=nil)
      @status_code = status_code
      @error = error
    end

    def to_s
      "ScanError status_code:#{@status_code} cause:#{@error.to_s}"
    end

  end
end
