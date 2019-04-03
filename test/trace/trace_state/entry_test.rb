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


require "test_helper"

describe OpenCensus::Trace::TraceState::Entry do
  describe "#create" do
    it "create entry with valid key and value" do
      entry = OpenCensus::Trace::TraceState::Entry.new "key", "value"

      entry.key.must_equal "key"
      entry.value.must_equal "value"
    end
  end
  describe "key validations" do
    it "key is nil" do
      proc {
        OpenCensus::Trace::TraceState::Entry.new nil, "value"
      }.must_raise ArgumentError
    end

    it "size more then 256 chars" do
      key = "a"*257

      proc {
        OpenCensus::Trace::TraceState::Entry.new key, "value"
      }.must_raise ArgumentError
    end

    it "invalid first chars" do
      key = "1aaAbB"

      proc {
        OpenCensus::Trace::TraceState::Entry.new key, "value"
      }.must_raise ArgumentError

      key = "AaaAbB"

      proc {
        OpenCensus::Trace::TraceState::Entry.new key, "value"
      }.must_raise ArgumentError
    end

    it "include upercase chars" do
      key = "aaAbB"

      proc {
        OpenCensus::Trace::TraceState::Entry.new key, "value"
      }.must_raise ArgumentError
    end

    it "include chars not in allowrd chars set" do
      key = "aaAbB"
      key << ['z'.bytes.first + 1].pack('c')

      proc {
        OpenCensus::Trace::TraceState::Entry.new key, "value"
      }.must_raise ArgumentError
    end

    it "allowed all valid chars" do
      key = ("a".."z").to_a.join
      key << (0..9).to_a.join
      key << "_-*/"

      entry = OpenCensus::Trace::TraceState::Entry.new key, "value"
      entry.key.must_equal key
    end
  end

  describe "value validations" do
    it "value is nil" do
      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", nil
      }.must_raise ArgumentError
    end

    it "size more then 256 chars" do
      value = "v"*257
      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", value
      }.must_raise ArgumentError
    end

    it "start with space" do
      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", " value"
      }.must_raise ArgumentError
    end

    it "contain equal char" do
      value = "value=5"

      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", value
      }.must_raise ArgumentError
    end

    it "contain comma char" do
      value = "value,5"

      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", value
      }.must_raise ArgumentError
    end

    it "contain trailing space" do
      value = "value "

      proc {
        OpenCensus::Trace::TraceState::Entry.new "key", value
      }.must_raise ArgumentError
    end

    it "allowed all valid chars" do
      value = (" ".."~").to_a.join
      value.gsub!(/[\s=~,]/, '')

      entry = OpenCensus::Trace::TraceState::Entry.new "key", value
      entry.value.must_equal value
    end
  end
end
