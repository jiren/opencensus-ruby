require "test_helper"

describe OpenCensus::Tags::Tag do
  describe "create" do
    it "create tag" do
      tag = OpenCensus::Tags::Tag.new("key", "value")
      tag.key.must_equal "key"
      tag.value.must_equal "value"
      tag.ttl.must_be_nil
    end

    it "create tag with ttl" do
      tag = OpenCensus::Tags::Tag.new("key", "value", ttl: 10)
      tag.key.must_equal "key"
      tag.value.must_equal "value"
      tag.ttl.must_equal 10
    end

    describe "tag key validation" do
      it "raise error for empty key" do
        expect {
          raise OpenCensus::Tags::Tag.new("", "mobile-1.0")
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end

      it "raise error if key length more then 255 chars" do
        key = "k" * 256
        expect {
          raise OpenCensus::Tags::Tag.new(key, "mobile-1.0")
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end

      it "raise error if key contains non printable chars less then 32 ascii code" do
        key = "key#{[31].pack('c')}-test"
        expect {
          raise OpenCensus::Tags::Tag.new(key, "mobile-1.0")
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end

      it "raise error if key contains non printable chars greater then 126 ascii code" do
        key = "key#{[127].pack('c')}-test"
        expect {
          raise OpenCensus::Tags::Tag.new(key, "mobile-1.0")
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end
    end

    describe "tag value validation" do
      it "raise error if value length more then 255 chars" do
        value = "v" * 256
        expect {
          OpenCensus::Tags::Tag.new("frontend", value)
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end

      it "raise error if value contains non printable chars less then 32 ascii code" do
        value = "value#{[31].pack('c')}-test"
        expect {
          OpenCensus::Tags::Tag.new("frontend", value)
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end

      it "raise error if value contains non printable chars greater then 126 ascii code" do
        value = "value#{[127].pack('c')}-test"
        expect {
          OpenCensus::Tags::Tag.new("frontend", value)
        }.must_raise OpenCensus::Tags::Tag::InvalidTagError
      end
    end
  end
end
