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


require "test_helper"

describe OpenCensus::Trace::Exporters::RunningSpanStore do
  describe "export" do
    before {
      OpenCensus::Trace.unset_span_context
    }

    after {
      OpenCensus::Trace.unset_span_context
    }

    let(:exporter) {
      OpenCensus::Trace::Exporters::RunningSpanStore.new
    }

    it "should export multiple active spans and get summary" do
      OpenCensus::Trace.start_request_trace do |span_context|
        OpenCensus::Trace.in_span "span1" do |span1|
          exporter.spans.length.must_equal 1
          exporter.spans.first.name.to_s.must_equal "span1"

          OpenCensus::Trace.in_span "span2" do |span2_1|
            exporter.spans.length.must_equal 2
            exporter.spans.map{|s| s.name.to_s }.sort.must_equal ["span1", "span2"]

            OpenCensus::Trace.in_span "span2" do |span2_2|
              exporter.spans.length.must_equal 3
              exporter.spans.map{|s| s.name.to_s }.sort.must_equal ["span1", "span2", "span2"]
              exporter.summary.must_equal({ "span1" => 1, "span2" => 2})
            end

            exporter.spans.length.must_equal 2
          end
          exporter.spans.length.must_equal 1
        end

        # All span ended.
        exporter.spans.length.must_equal 0
      end
    end

    it "should return list of spans by name" do
      OpenCensus::Trace.start_request_trace do |span_context|
        OpenCensus::Trace.in_span "span1" do |span1|
          OpenCensus::Trace.in_span "span2" do |span2|
            OpenCensus::Trace.in_span "span2" do |span2_2|
              exporter["span1"].length.must_equal 1
              exporter["span2"].length.must_equal 2
            end
          end
        end
      end
    end
  end
end
