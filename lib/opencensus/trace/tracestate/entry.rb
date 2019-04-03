# frozen_string_literal: true

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


require "forwardable"

module OpenCensus
  module Trace
    # Tracestate
    class Tracestate
      # @private
      #
      # Entry is pair of key and value.
      class Entry
        # Maximum size of key.
        MAX_KEY_SIZE = 256

        # Maximumsize of value.
        MAX_VALUE_SIZE = 256

        # @return [String]
        attr_reader :key

        # @return [String]
        attr_reader :value

        # Create instance of Tracestate Entry
        #
        # @param [String] key Key of the entry.
        #   The key must begin with a lowercase letter, and can only contain
        #  lowercase letters 'a'-'z', digits '0'-'9', underscores '_', dashes
        #  '-', asterisks '*', and forward slashes '/'.
        # @param [String] value Value of the entry.
        #   The value is opaque string up to 256 characters printable ASCII
        #   RFC0020 characters (i.e., the range 0x20 to 0x7E) except ','
        #   and '='.
        #   Note that this also excludes tabs, newlines, carriage returns, etc.
        #
        def initialize key, value
          @key = key
          @value = value
        end

        # Check entry has valid key and value format.
        # @return [Boolean]
        def valid?
          (validate_key(key) && validate_value(value)) == true
        end

        private

        # Key format regular expression.
        # The key must begin with a lowercase letter, and can only contain
        # lowercase letters 'a'-'z', digits '0'-'9', underscores '_', dashes
        # '-', asterisks '*', and forward slashes '/'.
        KEY_FORMAT = /\A[a-z][a-z\d\-_*\/]*\z/

        # Check key format
        #
        # @param [String] key
        # @return [Boolean]
        #
        def validate_key key
          key && key.length <= MAX_KEY_SIZE && KEY_FORMAT.match?(key)
        end

        # Check value format
        #
        # @param [String] value
        # @return [Boolean]
        #
        def validate_value value
          if value.nil? || value.length > MAX_VALUE_SIZE || value[0] == " "
            return false
          end

          value.chars.none? do |c|
            c == "," || c == "=" || c <= " " || c >= "~"
          end
        end
      end
    end
  end
end
