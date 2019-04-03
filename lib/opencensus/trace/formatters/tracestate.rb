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
    module Formatters
      ##
      # This formatter serializes and deserializes TraceState according to
      # specification. See
      # [documentation](https://w3c.github.io/trace-context/#tracestate-field)
      #
      class Tracestate
        # @private
        #
        # The header name used for the Tracestate specification.
        HEADER_NAME = "tracestate".freeze

        # @private
        #
        # The rack environment header used for the Tracestate header.
        #
        #
        RACK_HEADER_NAME = "HTTP_TRACESTATE".freeze

        # @private
        #
        # Tracestate entry delimiter
        ENTRY_DELIMITER = ","

        # @private
        #
        # Tracestate entry delimiter format
        ENTRY_DELIMITER_FORMAT = /[ \t]*#{ENTRY_DELIMITER}[ \t]*/

        # @private
        #
        # Tracestate entry member delimiter
        KEY_VALUE_DELIMITER = "=".freeze

        # Returns the name of the header used for tracestate propagation.
        #
        # @return [String]
        #
        def header_name
          HEADER_NAME
        end

        # Deserialize a trace state header into a Tracestate object.
        #
        # @param [String] header
        # @return [Tracestate, nil]
        #
        def deserialize header
          entries = header.split ENTRY_DELIMITER

          if entries.length > OpenCensus::Trace::Tracestate::MAX_ENTRIES
            return nil
          end

          tracestate = OpenCensus::Trace::Tracestate.new
          entries.each do |e|
            key_value = e.strip.split KEY_VALUE_DELIMITER
            return nil if key_value.length != 2
            tracestate.add key_value[0], key_value[1]
          end

          return tracestate if tracestate.valid?
        end

        # Serialize a Tracestate object.
        #
        # @param [Tracestate] tracestate
        # @return [String]
        #
        def serialize tracestate
          entries = tracestate.map do |e|
            "#{e.key}#{KEY_VALUE_DELIMITER}#{e.value}"
          end

          entries.join ENTRY_DELIMITER
        end
      end
    end
  end
end
