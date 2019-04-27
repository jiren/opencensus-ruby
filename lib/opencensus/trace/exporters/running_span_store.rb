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


require "set"

module OpenCensus
  module Trace
    module Exporters
      # # RunningSpanStore
      #
      # This store allows users to access in-process information about
      # all running spans in current span context. This functionality allows
      # users to debug stuck operations or long living operations.
      #
      class RunningSpanStore
        # rubocop:disable Style/EmptyMethod

        # Export spans
        #
        # @param [Array<Span>]
        def export spans
        end

        # rubocop:enable Style/EmptyMethod

        # Get spans by span name.
        #
        # @param [String] span_name
        # @return [Array<Span>]
        def [] span_name
          store[span_name]
        end

        # Get all active spans.
        #
        # @return [Array<Span>]
        def spans
          span_context = Trace.span_context
          return [] unless span_context

          span_builders = Set.new
          loop do
            span_context.contained_span_builders.each do |sb|
              span_builders << sb unless sb.finished?
            end

            span_context = span_context.parent
            break unless span_context
          end

          span_builders.map do |sb|
            sb.to_span validate_timestamps: false
          end
        end

        # Store of the exported spans.
        #
        # @return [Hash<String, Array<Span>>]
        def store
          spans.each_with_object({}) do |span, r|
            r[span.name.to_s] ||= []
            r[span.name.to_s] << r
          end
        end

        # Summary of number of spans based on span name.
        #
        # @return [Hash<String, Integer>] Returns map of span count for each
        #   each unique span.
        def summary
          store.each_with_object({}) do |(name, spans), r|
            r[name] = spans.length
          end
        end
      end
    end
  end
end
