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


require "forwardable"
require "opencensus/trace/trace_state/entry"

module OpenCensus
  module Trace
    # # TraceState
    #
    # TraceState carries information about request position in multiple
    # distributed tracing graphs in a list of key value pair. It is a list of
    # Tracestate. Entry with a maximum of 32 members in the list.
    #
    # @see the https://github.com/w3c/distributed-tracing for more details.
    class TraceState
      extend Forwardable

      # Maximum numbers of members in the tracestate.
      MAX_ENTRIES = 32

      # Create a TraceState object.
      #
      def initialize
        @entries = []
      end

      # Add or update entry
      #
      # @param [String] key Key of the entry.
      #   The key must begin with a lowercase letter, and can only contain
      #  lowercase letters 'a'-'z', digits '0'-'9', underscores '_', dashes
      #  '-', asterisks '*', and forward slashes '/'.
      # @param [String] value Value of the entry.
      #   The value is opaque string up to 256 characters printable ASCII
      #   RFC0020 characters (i.e., the range 0x20 to 0x7E) except ',' and '='.
      #   Note that this also excludes tabs, newlines, carriage returns, etc.
      # @raise [ArgumentError] If invalid format of key or value.
      # @return [Entry]
      #
      def add key, value
        if @entries.length >= MAX_ENTRIES
          raise ArgumentError, "Maximum #{MAX_ENTRIES} entries are allowed"
        end

        # To maintain order, delete entry and add front of the list.
        @entries.delete_if { |entry| entry.key == key }
        entry = Entry.new key, value
        @entries.unshift entry
        entry
      end

      # Delete entry
      #
      # @param [String] key Key of the entry.
      #
      def delete key
        @entries.delete_if { |e| e.key == key }
      end

      # Get value.
      #
      # Get value of specified key or null if if entry not exists for
      # specified key.
      #
      # @return [String, nil]
      #
      def get_value key
        entry = @entries.find { |e| e.key == key }
        entry ? entry.value : nil
      end

      # @!method each
      #   @see Array#each
      # @!method delete_if
      #   @see Array#delete_if
      # @!method length
      #   @see Array#length
      # @!method empty?
      #   @see Array#empty?
      # @!method []
      #   @see Array#[]
      def_delegators :@entries, :each, :delete_if, :length, :empty?, :[]
    end
  end
end
