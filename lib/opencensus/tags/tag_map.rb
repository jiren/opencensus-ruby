# frozen_string_literal: true


require "forwardable"
require "opencensus/tags/tag"

module OpenCensus
  module Tags
    # # TagMap
    #
    # Collection of tag key and value.
    # @example
    #
    #  tag_map = OpenCensus::Tags::OpenCensus.new
    #
    #  # Add or update
    #  tag_map["key1"] = "value1"
    #  tag_map["key2"] = "value2"
    #
    #  # Get value
    #  tag_map["key1"] # value1
    #
    #  # Delete
    #  tag_map.delete "key1"
    #
    #  # Iterate
    #  tag_map.each do |key, value|
    #    p key
    #    p value
    #  end
    #
    #  # Length
    #  tag_map.length # 1
    #
    # @example Create tag map from hash
    #
    #   tag_map = OpenCensus::Tags::OpenCensus.new({ "key1" => "value1"})
    #
    class TagMap
      extend Forwardable

      # Create a tag map. It is a map of tags from key to value.
      # @param [Array<Tag>] tags Tags list with string key and value and
      #   metadata.
      def initialize tags = []
        @tags = tags.each_with_object({}) { |tag, r| r[tag.key] = tag }
      end

      # Insert tag.
      # @param [Tag] tag
      def << tag
        @tags[tag.key] = tag
      end

      # Get all tags
      # @param [Array<Tag>]
      def tags
        @tags.values
      end

      # Get tag by key
      # @return [Tag]
      def [] key
        @tags[key]
      end

      # Convert tag map to binary string format.
      # @see [documentation](https://github.com/census-instrumentation/opencensus-specs/blob/master/encodings/BinaryEncoding.md#tag-context)
      # @return [String] Binary string
      #
      def to_binary
        Formatters::Binary.new.serialize self
      end

      # Create a tag map from the binary string.
      # @param [String] data Binary string data
      # @return [TagMap]
      #
      def self.from_binary data
        Formatters::Binary.new.deserialize data
      end

      # Delete tag by key
      # @param [String] key Tag key
      def delete key
        @tags.delete key
      end

      # @!method each
      #   @see Array#each
      # @!method delete_if
      #   @see Array#delete_if
      # @!method length
      #   @see Array#length
      # @!method empty?
      #   @see Array#empty?
      def_delegators :tags, :each, :length, :empty?
    end
  end
end
