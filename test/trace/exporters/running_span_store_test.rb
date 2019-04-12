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
    let(:root_context) { OpenCensus::Trace::SpanContext.create_root }
    let(:span1) { root_context.start_span "span1" }
    let(:context1) { span1.context }
    let(:span2) { context1.start_span "span2" }
    let(:context2) { span2.context }
    let(:span3) { context2.start_span "span3" }
    let(:running_span_store) {
      OpenCensus::Trace::Exporters::RunningSpanStore.new
    }

    it "should export active spans and get summary" do
      running_span_store.export [span1]
      running_span_store.spans.length.must_equal 1

      span_summary = running_span_store.summary
      span_summary.length.must_equal 1
      span_summary["span1"].number_of_running_spans.must_equal 1

      running_span_store.export [span2]
      span_summary = running_span_store.summary
      span_summary["span1"].must_be_nil
      span_summary["span2"].number_of_running_spans.must_equal 1
    end

    it "should export active spans with the same name and increment counter" do
      running_span_store.export [span1, span1]
      span_summary = running_span_store.summary
      span_summary.length.must_equal 1
      span_summary["span1"].number_of_running_spans.must_equal 2
    end

    describe "filter" do
      it "should filter span by name" do
        running_span_store.export [span1, span1, span2, span3]

        spans = running_span_store.filter "span1"
        spans.length.must_equal 2
        spans.each do |span|
          span.name.to_s.must_equal "span1"
        end

        spans = running_span_store.filter "span2"
        spans.length.must_equal 1
        spans[0].name.to_s.must_equal "span2"
      end

      it "should filter span by name and limit" do
        running_span_store.export [span1, span1, span2, span3]

        spans = running_span_store.filter "span1", limit: 1
        spans.length.must_equal 1
        spans[0].name.to_s.must_equal "span1"
      end
    end
  end
end
