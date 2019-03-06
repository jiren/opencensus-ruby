# frozen_string_literal: true


module OpenCensus
  module Tags
    # # Tag
    #
    # A Tag consists of Key, Value and Metadata(TagTTL)
    #
    class Tag
      # Invalid tag error.
      class InvalidTagError < StandardError; end

      # The maximum length for a tag key and tag value
      MAX_LENGTH = 255

      # @return [String]
      attr_reader :key

      # @return [String]
      attr_reader :value

      # @return [Integer] Represents number of hops a tag can propagate.
      attr_reader :ttl

      # Create a tag
      # @param [String] key Tag key
      # @param [String] value Tag value
      # @param [Integer] ttl Tag Represents number of hops a tag can propagate.
      # @raise [InvalidTagError] If invalid tag key or value.
      #
      def initialize key, value, ttl: nil
        validate_key! key
        validate_value! value

        @key = key
        @value = value
        @ttl = ttl
      end

      # Tag can propagate
      def propagation?
        @ttl == -1 || @ttl > 0
      end

      private

      # Validate tag key.
      # @param [String] value
      # @raise [InvalidTagError] If key is empty, length grater then 255
      #   characters or contains non printable characters
      #
      def validate_key! value
        if value.empty? || value.length > MAX_LENGTH || !printable_str?(value)
          raise InvalidTagError, "Invalid tag key #{key}"
        end
      end

      # Validate tag value.
      # @param [String] value
      # @raise [InvalidTagError] If value length grater then 255 characters
      #   or contains non printable characters
      #
      def validate_value! value
        if (value && value.length > MAX_LENGTH) || !printable_str?(value)
          raise InvalidTagError, "Invalid tag value #{value}"
        end
      end

      # Check string is printable.
      # @param [String] str
      # @return [Boolean]
      #
      def printable_str? str
        str.bytes.none? { |b| b < 32 || b > 126 }
      end
    end
  end
end
