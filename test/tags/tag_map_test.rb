require "test_helper"

describe OpenCensus::Tags::TagMap do
  let(:tag) {
    OpenCensus::Tags::Tag.new "frontend", "mobile-1.0"
  }

  describe "create" do
    it "create tags map with defaults" do
      tag_map = OpenCensus::Tags::TagMap.new
      tag_map.length.must_equal 0
    end

    it "create tags map with tags" do
      tag_map = OpenCensus::Tags::TagMap.new [tag]
      tag_map.length.must_equal 1
      tag_map["frontend"].value.must_equal "mobile-1.0"
    end
  end

  describe "add tag to tag map" do
    it "set tag key value" do
      tag_map = OpenCensus::Tags::TagMap.new
      tag_map << OpenCensus::Tags::Tag.new("frontend", "mobile-1.0")
      tag_map.length.must_equal 1
      tag_map["frontend"].value.must_equal "mobile-1.0"
    end

    it "allow empty tag value" do
      tag_map = OpenCensus::Tags::TagMap.new
      tag_map << OpenCensus::Tags::Tag.new("frontend", "")
      tag_map.length.must_equal 1
      tag_map["frontend"].value.must_equal ""
    end
  end

  describe "delete" do
    it "delete tag" do
      tag_map = OpenCensus::Tags::TagMap.new [tag]

      tag_map.delete "frontend"
      tag_map["frontend"].must_be_nil
      tag_map.length.must_equal 0
    end
  end

  describe "binary formatter" do
    it "serialize tag map to binary format" do
      tag_map = OpenCensus::Tags::TagMap.new
      tag_map << OpenCensus::Tags::Tag.new("key1", "val1")
      tag_map << OpenCensus::Tags::Tag.new("key2", "val2")

      expected_binary = "\x00\x00\x04key1\x04val1\x00\x04key2\x04val2"
      tag_map.to_binary.must_equal expected_binary
    end

    it "deserialize binary format and create tag map" do
      binary = "\x00\x00\x04key1\x04val1\x00\x04key2\x04val2"

      tag_map = OpenCensus::Tags::TagMap.from_binary binary
      tag_map.length.must_equal 2
      tag_map["key1"].value.must_equal "val1"
      tag_map["key2"].value.must_equal "val2"
    end
  end
end
