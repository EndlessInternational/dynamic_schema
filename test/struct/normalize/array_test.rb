require_relative '../../test_helper'

module StructTests
  module Normalize

    class ArrayTest < Minitest::Test
      include TestHelper

      def test_normalizes_each_item_in_array
        klass = DynamicSchema::Struct.define do
          tags String, array: true, normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( tags: [ 'one', 'two', 'three' ] )
        assert_equal [ 'ONE', 'TWO', 'THREE' ], struct.tags
      end

      def test_normalizes_singular_value_on_array_attribute
        klass = DynamicSchema::Struct.define do
          tags String, array: true, normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( tags: 'single' )
        assert_equal [ 'SINGLE' ], struct.tags
      end

      def test_normalize_receives_individual_values_not_array
        received_values = []
        klass = DynamicSchema::Struct.define do
          numbers Integer, array: true, normalize: ->( v ) {
            received_values << v
            v
          }
        end

        klass.build( numbers: [ 1, 2, 3 ] ).numbers
        assert_equal [ 1, 2, 3 ], received_values
      end
    end

  end
end
