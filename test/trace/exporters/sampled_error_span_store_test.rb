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

describe OpenCensus::Trace::Exporters::SampledErrorSpanStore do
  describe "export" do
    before {
      OpenCensus::Trace.unset_span_context
    }
    after {
      OpenCensus::Trace.unset_span_context
      exporter.clear
    }
    let(:exporter) {
      OpenCensus::Trace::Exporters::SampledErrorSpanStore.new
    }
    let(:span_context) {
      OpenCensus::Trace::SpanContext.create_root
    }

    it "should export error spans" do
      span_builder = span_context.start_span "span-not-found"
      span_builder.set_http_status 404, "Not found"
      span_builder.finish!
      span = span_builder.to_span

      exporter.export [span]
      exporter[OpenCensus::Trace::Status::NOT_FOUND].length.must_equal 1
      exporter.spans.length.must_equal 1
      exporter.clear
      exporter.spans.length.must_equal 0
    end

    it "should not export non error spans" do
      span_builder = span_context.start_span "span-ok"
      span_builder.set_http_status 200, "OK"
      span_builder.finish!
      span = span_builder.to_span

      exporter.export [span]
      exporter.spans.length.must_equal 0
    end

    it "should export spans and generate summary" do
      spans = {
        "span-not-found-1" =>  404,
        "span-not-found-2" =>  404,
        "span-gateway-timeout" => 504
      }.map do |name, error_code|
        sb = span_context.start_span name
        sb.set_http_status error_code, name
        sb.finish!
        sb.to_span
      end

      exporter.export spans
      exporter.spans.length.must_equal 3
      exporter.summary.must_equal({
        OpenCensus::Trace::Status::NOT_FOUND => 2,
        OpenCensus::Trace::Status::DEADLINE_EXCEEDED => 1
      })
    end
  end
end
