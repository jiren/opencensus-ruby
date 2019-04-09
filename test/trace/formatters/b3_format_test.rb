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

describe OpenCensus::Trace::Formatters::B3Format do
  let(:trace_id) { "ff000000000000000000000000000041" }
  let(:span_id) { "0000000000000041"}

  describe "create" do
    it "single header formatter" do
      formatter = OpenCensus::Trace::Formatters::B3Format.new_single_header

      formatter.header_name.must_equal "b3"
      formatter.rack_header_name.must_equal "HTTP_B3"
    end

    it "multiple headers formatter" do
      formatter = OpenCensus::Trace::Formatters::B3Format.new_multi_headers

      formatter.header_name.must_equal "X-B3-TraceId"
      formatter.rack_header_name.must_equal "HTTP_X_B3_TRACEID"
    end
  end

  describe "deserialize" do
    let(:formatter) {
      OpenCensus::Trace::Formatters::B3Format.new_single_header
    }

    it "should return nil if headers are empty" do
      data = formatter.deserialize({})
      data.must_be_nil
    end

    it "should return nil on trace_id value nil" do
      data = formatter.deserialize({ trace_id: nil })
      data.must_be_nil
    end

    it "should return nil on span_id value nil" do
      data = formatter.deserialize(
        trace_id: trace_id,
        span_id: nil
      )
      data.must_be_nil
    end

    it "should parse a valid format without sampling data and set sampling to accept" do
      data = formatter.deserialize(
        trace_id: trace_id,
        span_id: span_id
      )
      data.trace_id.must_equal trace_id
      data.span_id.must_equal span_id
      data.trace_options.must_equal 1
    end

    it "should parse a valid format with deny sampling data" do
      data = formatter.deserialize(
        trace_id: trace_id,
        span_id: span_id,
        sampled: "0"
      )
      data.trace_id.must_equal trace_id
      data.span_id.must_equal span_id
      data.trace_options.must_equal 0
    end

    it "should parse a valid format with accept sampling data" do
      data = formatter.deserialize(
        trace_id: trace_id,
        span_id: span_id,
        sampled: "1"
      )
      data.trace_id.must_equal trace_id
      data.span_id.must_equal span_id
      data.trace_options.must_equal 1
    end

    it "should parse a valid format with debug sampling data" do
      data = formatter.deserialize(
        trace_id: trace_id,
        span_id: span_id,
        sampled: "d"
      )
      data.trace_id.must_equal trace_id
      data.span_id.must_equal span_id
      data.trace_options.must_equal 1
    end
  end

  describe "single_header_formatter" do
    let(:formatter) {
      OpenCensus::Trace::Formatters::B3Format.new_single_header
    }

    describe "rack_deserialize" do
      let(:header_name) { "HTTP_B3" }

      it "should return nil for empty header" do
        data = formatter.rack_deserialize({ header_name => "" })
        data.must_be_nil
      end

      it "should return nil for only trace value header" do
        data = formatter.rack_deserialize({ header_name => trace_id })
        data.must_be_nil
      end

      it "should parse a valid formatwithout sampling data" do
        data = formatter.rack_deserialize({
          header_name => "#{trace_id}-#{span_id}"
        })
        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 1
      end

      it "should parse a valid format with deny sampling data" do
        data = formatter.rack_deserialize({
          header_name => "#{trace_id}-#{span_id}-0"
        })
        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 0
      end

      it "should parse a valid format with accept sampling data" do
        data = formatter.rack_deserialize({
          header_name => "#{trace_id}-#{span_id}-1"
        })
        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 1
      end

      it "should parse a valid format with debug sampling data" do
        data = formatter.rack_deserialize({
          header_name => "#{trace_id}-#{span_id}-d"
        })
        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 1
      end

      it "should parse a valid format with invalid sampling data" do
        data = formatter.rack_deserialize({
          header_name => "#{trace_id}-#{span_id}-invalid"
        })
        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 0
      end
    end
  end

  describe "multi_header_formatter" do
    let(:formatter) {
      OpenCensus::Trace::Formatters::B3Format.new_multi_headers
    }
    describe "rack_deserialize" do
      it "should return nil for empty headers" do
        data = formatter.rack_deserialize({})
        data.must_be_nil
      end

      it "should parse a valid format" do
        data = formatter.rack_deserialize({
          "HTTP_X_B3_TRACEID" => trace_id,
          "HTTP_X_B3_SPANID" => span_id,
          "HTTP_X_B3_SAMPLED" => "1"
        })

        data.trace_id.must_equal trace_id
        data.span_id.must_equal span_id
        data.trace_options.must_equal 1
      end
    end
  end

  describe "serialize" do
    let(:formatter) {
      OpenCensus::Trace::Formatters::B3Format.new_multi_headers
    }
    let(:trace_id_header) { "X-B3-TraceId" }
    let(:span_id_header) { "X-B3-SpanId" }
    let(:sampled_header) { "X-B3-Sampled" }
    let(:trace_data) do
      OpenCensus::Trace::SpanContext::TraceData.new(trace_id, {})
    end
    let(:span_context) do
      OpenCensus::Trace::SpanContext.new trace_data, nil, span_id, 1, nil
    end

    it "should serialize a SpanContext object" do
      headers = formatter.serialize span_context
      headers[trace_id_header].must_equal trace_id
      headers[span_id_header].must_equal span_id
      headers[sampled_header].must_equal "1"
    end
  end
end
