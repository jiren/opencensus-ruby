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
    module Exporters
      # # SampledErrorSpanStore
      #
      # This store allows users to access in-process information about
      # sampled spans based on errors.
      #
      class SampledErrorSpanStore
        # Store of the exported error spans.
        #
        # @return [Hash<Integer, Array<Span>>]
        attr_reader :store

        # Create instance of Sampled error span store.
        def initialize
          @store = Hash.new { |h, k| h[k] = [] }
        end

        # Export captured sampled spans
        #
        # @param [Array<Span>] spans The captured spans.
        def export spans
          spans.each do |span|
            @store[span.status.code] << span if span.status.error?
          end
        end

        # Get span list by span name, error code.
        #
        # @param [String, Integer] code Error code.
        #   @see Trace::Status for error codes.
        # @return [Array<Span>]
        def [] code
          @store[code]
        end

        # Clear span store
        def clear
          @store.clear
        end

        # Get all error spans.
        #
        # @return [Array<Span>]
        def spans
          @store.values.flatten
        end

        # Summary of number of spans baed on error code.
        #
        # @return [Hash<String | Integer, Integer>]
        def summary
          @store.each_with_object({}) do |(key, spans), r|
            r[key] = spans.length
          end
        end
      end
    end
  end
end
