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
      # # SampledLatencySpanStore
      #
      # This store allows users to access in-process information about sampled
      # spans based on latency.
      #
      class SampledLatencySpanStore
        # One micro second in seconds
        #
        # @return [Float]
        MICRO_TO_SECONDS = 1.0 / 10 ** 6

        # One milli seconds to seconds
        #
        # @return [Float]
        MILLI_TO_SECONDS = 1.0 / 1000

        # Default latencies bucket boundries in seconds
        #
        # @return [Array<Integer,Float>]
        DEFAULT_BUCKET_BOUNDRIES = [
          (10 * MICRO_TO_SECONDS).round(6),  # 10us
          (100 * MICRO_TO_SECONDS).round(6), # 100us
          MILLI_TO_SECONDS,                  # 1ms
          10 * MILLI_TO_SECONDS,             # 10ms
          100 * MILLI_TO_SECONDS,            # 100ms
          1,                                 # 1sec
          10,                                # 10sec
          60                                 # 1min
        ].freeze

        # Span latency bucket boundries
        #
        # @return [Array<Integer,Float>]
        attr_reader :bucket_boundries

        # Latency span buckets
        #
        # @return [Array<Spans>]
        attr_reader :buckets

        # Create instance of sampled span store
        #
        # @param [Array<Integer,Float>, nil] bucket_boundries Latency buckets
        #   boundries. Default value is {DEFAULT_BUCKET_BOUNDRIES}
        def initialize bucket_boundries = nil
          @bucket_boundries = bucket_boundries || DEFAULT_BUCKET_BOUNDRIES
          @buckets = Array.new(@bucket_boundries.length + 1) { [] }
        end

        # Export captured sampled spans.
        #
        # @param [Array<Span>] spans The captured spans.
        def export spans
          spans.each do |span|
            add span if span.status && !span.status.error?
          end
        end

        # Clear span store
        def clear
          @buckets.clear
        end

        # Filter spans by latency range and span name
        #
        # @param [Integer, Float] min The minimum latency in seconds.
        #   Minimum latency bound is inclusive.
        #   Default value is zero.
        # @param [Integer,Float, nil] max The maximum latency in seconds.
        #   Default is `Float::INFINITY`.
        #   Minimum latency bound is exlusive.
        # @param [String] span_name The name of the span.
        #   Default is nil and nil span name value returns all filterd spans
        #   based on latency range.
        # @return [Array<Span>]
        def filter min: nil, max: nil, span_name: nil
          return spans if min.nil? && max.nil? && span_name.nil?

          min ||= 0
          max ||= Float::INFINITY
          return [] if min > max

          spans.select do |span|
            next if span_name && span_name != span.name.to_s
            latency = span.end_time - span.start_time
            latency >= min && latency < max
          end
        end

        # Get all sampled spans.
        #
        # @return [Array<Span>]
        def spans
          @buckets.flatten
        end

        # Summary of number of spans based on minimum and maximum latency.
        #
        # @return [Array<Hash<Symbol, Number>>]
        def summary
          result = []
          @buckets.each_with_index do |spans, index|
            min, max = get_bucket_bounds index
            result << {
              min: min,
              max: max,
              count: spans.length
            }
          end
          result
        end

        private

        # Add span to the buckets of the sampled spans
        #
        # @param [Span] span
        def add span
          latency = span.end_time - span.start_time
          bucket_index = nil
          @bucket_boundries.each_with_index do |v, i|
            if latency < v
              bucket_index = i
              break
            end
          end
          bucket_index ||= @buckets.length - 1
          @buckets[bucket_index] << span
        end

        # Get latency bucket bounds.
        #
        # @param [Integer] index
        # @return [Array<Integer, Float>] The lower and upper bounds for a
        #   latency bucket
        def get_bucket_bounds index
          return [0, bucket_boundries[index]] if index.zero?

          if index == bucket_boundries.length
            return [bucket_boundries[index - 1], Float::INFINITY]
          end

          [bucket_boundries[index - 1], bucket_boundries[index]]
        end
      end
    end
  end
end
