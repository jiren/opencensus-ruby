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
      # This formatter serializes and deserializes span context according to
      # the B3 format specification. See
      # [documentation](https://github.com/openzipkin/b3-propagation/blob/master/README.md#http-encodings).
      #
      class B3Format
        # The outgoing header used for the single B3Format header specification.
        #
        # @private
        #
        SINGLE_HEADER_NAME = "b3"

        # The outgoing headers used for the headers B3Format specification.
        #
        # @private
        #
        MULTI_HEADER_NAMES = {
          trace_id: "X-B3-TraceId",
          span_id: "X-B3-SpanId",
          parent_span_id: "X-B3-ParentSpanId",
          sampled: "X-B3-Sampled"
        }.freeze

        # The rack environment header used for the single B3Format header
        # specification
        #
        # @private
        #
        RACK_SINGLE_HEADER_NAME = "HTTP_B3"

        # The rack environment header used for the multiple headers B3Format
        # specification
        #
        # @private
        #
        RACK_MULTI_HEADERS_NAMES = {
          trace_id: "HTTP_X_B3_TRACEID",
          span_id: "HTTP_X_B3_SPANID",
          parent_span_id: "HTTP_X_B3_PARENTSPANID",
          sampled: "HTTP_X_B3_SAMPLED"
        }.freeze

        # Not sample
        #
        # @private
        #
        NOT_SAMPLED_VALUE = 0x00

        # Sample value
        #
        # @private
        #
        SAMPLED_VALUE = 0x01

        # Debig sampled value
        #
        # @private
        DEBUG_SAMPLED_VALUE = "d"

        # Returns the name of the header used for context propagation.
        #
        # @return [String]
        attr_reader :header_name

        # Returns the name of the rack_environment header to use when parsing
        # context from an incoming request.
        #
        # @return [String]
        attr_reader :rack_header_name

        # @private
        def initialize header_name, rack_header_name
          @header_name = header_name
          @rack_header_name = rack_header_name
        end

        # Create instance of single header b3 formatter.
        # @return [B3Format]
        #
        def self.new_single_header
          new SINGLE_HEADER_NAME, RACK_SINGLE_HEADER_NAME
        end

        # Create instance of multiple headers b3 formatter.
        # @return [B3Format]
        #
        def self.new_multi_headers
          new MULTI_HEADER_NAMES[:trace_id], RACK_MULTI_HEADERS_NAMES[:trace_id]
        end

        ##
        # Deserialize a trace context headers into a TraceContext object.
        #
        # @param [Hash<Symbol,String>] headers
        # @return [TraceContextData, nil]
        #
        def deserialize headers
          return nil if headers[:trace_id].nil? || headers[:span_id].nil?

          sampled = headers[:sampled]
          trace_options = if sampled.nil? || sampled == DEBUG_SAMPLED_VALUE
                            SAMPLED_VALUE
                          else
                            sampled.to_i
                          end

          TraceContextData.new \
            headers[:trace_id],
            headers[:span_id],
            trace_options
        end

        ##
        # Serialize a TraceContextData object.
        #
        # @param [TraceContextData] trace_context
        # @return [Hash<Symbol,String>] Hash of the TraceId, SpanId,
        #   SamplingState.
        #
        def serialize trace_context
          {
            MULTI_HEADER_NAMES[:trace_id] => trace_context.trace_id,
            MULTI_HEADER_NAMES[:span_id] => trace_context.span_id,
            MULTI_HEADER_NAMES[:sampled] => trace_context.trace_options.to_s
          }
        end
        alias :headers_serialize :serialize

        # Deserialize rack headers
        #
        # @return [Hash<Symbol, String>] Hash of the TraceId, SpanId,
        #   SamplingState, ParentSpanId
        #
        def rack_deserialize env
          headers = if rack_header_name == RACK_SINGLE_HEADER_NAME
                      single_header_deserialize env
                    else
                      multi_header_deserialize env
                    end
          deserialize headers
        end

        private

        # Deserialize single header state.
        # Header format : {TraceId}-{SpanId}-{SamplingState}-{ParentSpanId}
        #
        # @param [Hash] env The rack environment
        # @return [Hash<Symbol, String>]
        #
        def single_header_deserialize env
          fields = env[rack_header_name].split("-")

          {
            trace_id: fields[0],
            span_id: fields[1],
            sampled: fields[2],
            parent_span_id: fields[3]
          }
        end

        # Fetch multiple headers from rack env.
        #
        # @param [Hash] env The rack environment
        # @return [Hash<Symbol,String>]
        #
        def multi_header_deserialize env
          RACK_MULTI_HEADERS_NAMES.each_with_object({}).each do |(k, v), r|
            r[k] = env[v]
          end
        end
      end
    end
  end
end
