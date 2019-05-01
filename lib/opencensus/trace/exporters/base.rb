# frozen_string_literal: true

# Copyright 2019 OpenCensus Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module OpenCensus
  module Trace
    ##
    #
    # Export handler is wrapper around exporter. It userfull start / stop
    # exporter at runtime.
    #
    #
    class Base
      module BaseMixin
        # Exporter status flag.
        #
        # @return [Boolean, nil]
        attr_accessor :stop

        # Stop exporter.
        def stop!
          self.stop = true
        end

        # Resume exporter.
        def resume!
          self.stop = false
        end

        # Check exporter is stopped?
        # @return [Boolean, nil]
        def stopped?
          stop
        end

        # Pass the captured spans.
        #
        # @param [Array<Span>] spans The captured spans.
        #
        def export spans
          raise "Implement export method."
        end
      end

      include BaseMixin
    end
  end
end
