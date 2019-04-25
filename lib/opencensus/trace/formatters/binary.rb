# Copyright 2017 OpenCensus Authors
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
      # This formatter serializes and deserializes span context according to
      # the OpenCensus' BinaryEncoding specification. See
      # [documentation](https://github.com/census-instrumentation/opencensus-specs/blob/master/encodings/BinaryEncoding.md).
      #
      class Binary
        ##
        # Internal format used to (un)pack binary data
        #
        # @private
        #
        BINARY_FORMAT = "CCH32CH16CC".freeze

        # Binary format version
        # @private
        #
        VERSION = 0

        # @private
        #
        TRACE_ID_FIELD_ID = 0

        # @private
        #
        SPAN_ID_FIELD_ID = 1

        # @private
        #
        TRACE_OPTION_FIELD_ID = 2

        ##
        # Deserialize a trace context header into a TraceContext object.
        #
        # @param [String] binary
        # @return [TraceContextData, nil]
        #
        def deserialize binary
          data = binary.unpack BINARY_FORMAT
          if data[0] == VERSION && data[1] == TRACE_ID_FIELD_ID && \
              data[3] == SPAN_ID_FIELD_ID && data[5] == TRACE_OPTION_FIELD_ID
            TraceContextData.new data[2], data[4], data[6]
          else
            nil
          end
        end

        ##
        # Serialize a TraceContextData object.
        #
        # @param [TraceContextData] trace_context
        # @return [String]
        #
        def serialize trace_context
          [
            VERSION,
            TRACE_ID_FIELD_ID,
            trace_context.trace_id,
            SPAN_ID_FIELD_ID,
            trace_context.span_id,
            TRACE_OPTION_FIELD_ID,
            trace_context.trace_options
          ].pack BINARY_FORMAT
        end
      end
    end
  end
end
