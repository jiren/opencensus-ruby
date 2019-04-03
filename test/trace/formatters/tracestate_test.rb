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

describe OpenCensus::Trace::Formatters::Tracestate do
  let(:formatter) { OpenCensus::Trace::Formatters::Tracestate.new }

  describe "deserialize" do
    it "should return nil on invalid format" do
      tracestate = formatter.deserialize "badvalue"
      tracestate.must_be_nil
    end

    it "should parse a valid format" do
      header = "foo=bar,test=test"

      tracestate = formatter.deserialize header
      tracestate.wont_be_nil
      tracestate.length.must_equal 2
      entry1 = tracestate[0]
      entry1.key.must_equal "test"
      entry1.value.must_equal "test"
      entry2 = tracestate[1]
      entry2.key.must_equal "foo"
      entry2.value.must_equal "bar"
    end

    it "should not parse a invalid format with comma" do
      header = "foo=bar;test=test"

      tracestate = formatter.deserialize header
      tracestate.must_be_nil
    end

    it "should not parse a invalid format with without delimiter" do
      header = "test-test"

      tracestate = formatter.deserialize header
      tracestate.must_be_nil
    end
  end

  describe "serialize" do
    it "should serialize a Tracestate object" do
      tracestate =  OpenCensus::Trace::Tracestate.new
      tracestate.add "key1", "val1"
      tracestate.add "key2", "val2"
      tracestate.add "key3", "val3"

      header = formatter.serialize tracestate
      header.must_equal "key3=val3,key2=val2,key1=val1"
    end
  end
end
