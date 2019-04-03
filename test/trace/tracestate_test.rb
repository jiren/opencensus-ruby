# Copyright 201 OpenCensus Authors
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

describe OpenCensus::Trace::Tracestate do
  describe "create" do
    it "create instance with default values" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.empty?.must_equal true
      trace_state.valid?.must_equal false
    end
  end

  describe "add or update entry" do
    it "add new entry" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.add "key", "val"
      trace_state.length.must_equal 1
      trace_state.get_value("key").must_equal "val"
    end

    it "add new entry in front of the list" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.add "key1", "val1"
      trace_state.add "key2", "val2"

      entry = trace_state[0]
      entry.key.must_equal "key2"
    end

    it "update entry and move entry in front of the list" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.add "key1", "val1"
      trace_state.add "key2", "val2"
      trace_state.add "key1", "val-1"

      trace_state.length.must_equal 2
      entry = trace_state[0]
      entry.key.must_equal "key1"
      entry.value.must_equal "val-1"
    end

    it "allow max 32 entries" do
      trace_state = OpenCensus::Trace::Tracestate.new

      32.times do |i|
        trace_state.add "key#{i+1}", "val#{i+1}"
      end
      trace_state.add("key33", "val33").must_equal false
    end

    it "set valid flag is entry is invalid" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.add("Key33", "val33 ").must_equal false
      trace_state.valid?.must_equal false
    end
  end

  describe "delete" do
    it "delete entry by key" do
      trace_state = OpenCensus::Trace::Tracestate.new
      trace_state.add "key1", "val1"
      trace_state.add "key2", "val2"
      trace_state.length.must_equal 2

      trace_state.delete "key2"
      trace_state.length.must_equal 1
      trace_state.get_value("key2").must_be_nil
    end
  end
end
