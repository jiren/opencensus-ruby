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

describe OpenCensus::Trace::Exporters::SampledLatencySpanStore do
  describe "export" do
    before {
      OpenCensus::Trace.unset_span_context
    }
    after {
      OpenCensus::Trace.unset_span_context
      exporter.clear
    }
    let(:exporter) {
      OpenCensus::Trace::Exporters::SampledLatencySpanStore.new
    }
    let(:span_context) {
      OpenCensus::Trace::SpanContext.create_root
    }

    it "should export spans" do
      spans = ["span1", "span2"].map do |name|
        sb = span_context.start_span name
        sb.set_http_status 200, "OK"
        sb.finish!
        sb.to_span
      end

      exporter.export spans
      exporter.spans.length.must_equal 2
      exporter.clear
      exporter.spans.length.must_equal 0
    end

    it "should not export error spans" do
      sb = span_context.start_span "span-not-found"
      sb.set_http_status 404, "Not found"
      sb.finish!
      span = sb.to_span

      exporter.export [span]
      exporter.spans.length.must_equal 0
    end

    it "should not export spans without status" do
      sb = span_context.start_span "span1"
      sb.finish!
      span = sb.to_span

      exporter.export [span]
      exporter.spans.length.must_equal 0
    end

    it "should export spans and get summary and apply filters" do
      time = Time.now.utc
      time_offsets = [1.0e-06, 0.001, 0.01, 0.1, 1, 1, 100]
      spans = []
      time_offsets.each_with_index do |offset, i|
        sb = span_context.start_span "span#{i}"
        sb.set_http_status 200, "OK"
        sb.finish!
        sb.instance_variable_set "@start_time", time
        sb.instance_variable_set "@end_time", (time + offset)
        spans << sb.to_span
      end

      exporter.export spans
      exporter.spans.length.must_equal time_offsets.length
      exporter.summary.must_equal([
        {:min=> 0, :max=> 1.0e-05, :count=> 1},
        {:min=> 1.0e-05, :max=> 0.0001, :count=> 0},
        {:min=> 0.0001, :max=> 0.001, :count=> 0},
        {:min=> 0.001, :max=> 0.01, :count=> 1},
        {:min=> 0.01, :max=> 0.1, :count=> 1},
        {:min=> 0.1, :max=> 1, :count=> 1},
        {:min=> 1, :max=> 10, :count=> 2},
        {:min=> 10, :max=> 60, :count=> 0},
        {:min=> 60, :max=> Float::INFINITY, :count=> 1}
      ])

      exporter.filter(min: 1).length.must_equal 3
      exporter.filter(min: 1.0e-06).length.must_equal time_offsets.length
      exporter.filter(min: 0.001, max: 0.1).length.must_equal 2
      exporter.filter(min: 0.001, max: 0.1, span_name: "span2").length.must_equal 1
      exporter.filter(min: 2, max: 1).length.must_equal 0
    end
  end
end
