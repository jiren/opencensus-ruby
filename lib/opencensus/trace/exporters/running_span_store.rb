# Copyright 2018 OpenCensus Authors
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


require "forwardable"

module OpenCensus
  module Trace
    module Exporters
      # RunningSpanStore allows users to access in-process information about
      # all running spans.
      #
      # The running spans tracking is available for all the spans with the option
      # This functionality allows users to debug stuck
      # operations or long living operations.
      #
      class RunningSpanStore
        extend Forwardable

        # Get list of recordred spans
        # @return [Array<OpenCensus::Trace::Span>]
        attr_reader :spans

        ##
        # Create a new RunningSpanStore exporter
        #
        def initialize
          @spans = []
        end

        # Store the captured spans.
        #
        # @param [Array<Span>] spans The captured spans.
        #
        def export spans
          @spans = spans
          nil
        end

        def_delegators :@spans, :clear, :select, :find_all, :find, :each

        # Filters runnings spans.
        #
        # @param [String] span_name The name of the span
        # @param [String] limit The maximum number of results to be returned
        #
        def filter span_name, limit: nil
          result = @spans.select { |span| span.name.to_s == span_name }
          limit ? result.take(limit) : result
        end

        # Struct that Span name and running span count.
        #
        SpanSummary = Struct.new :name, :number_of_running_spans

        # Get spans summary
        # @return [Hash<String, SpanSummary>]
        def summary
          @spans.each_with_object({}) do |span, r|
            r[span.name.to_s] ||=  SpanSummary.new span.name.to_s, 0
            r[span.name.to_s].number_of_running_spans += 1
          end
        end
      end
    end
  end
end
