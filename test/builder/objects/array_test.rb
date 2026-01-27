require_relative '../../test_helper'

module Builder
  module Objects

    class ArrayTest < Minitest::Test
      include TestHelper

      def test_array_of_objects
        builder = build_schema do
          items array: true do
            name String
            price Integer
          end
        end

        result = builder.build do
          items do
            name 'Desk'
            price 100
          end
          items do
            name 'Chair'
            price 50
          end
        end

        assert_equal 2, result[ :items ].length
        assert_equal 'Desk', result[ :items ][ 0 ][ :name ]
        assert_equal 100, result[ :items ][ 0 ][ :price ]
        assert_equal 'Chair', result[ :items ][ 1 ][ :name ]
        assert_equal 50, result[ :items ][ 1 ][ :price ]
      end

      def test_single_object_wrapped_in_array
        builder = build_schema do
          messages array: true do
            text String
          end
        end

        result = builder.build do
          messages do
            text 'Hello'
          end
        end

        assert_equal 1, result[ :messages ].length
        assert_equal 'Hello', result[ :messages ][ 0 ][ :text ]
      end

      def test_array_objects_with_hash_input
        builder = build_schema do
          items array: true do
            name String
            value Integer
          end
        end

        result = builder.build do
          items( { name: 'one', value: 1 } )
          items( { name: 'two', value: 2 } )
        end

        assert_equal 2, result[ :items ].length
        assert_equal 'one', result[ :items ][ 0 ][ :name ]
        assert_equal 'two', result[ :items ][ 1 ][ :name ]
      end

      def test_array_objects_with_defaults
        builder = build_schema do
          items array: true do
            name String
            quantity Integer, default: 1
          end
        end

        result = builder.build do
          items { name 'Widget' }
          items { name 'Gadget' }
        end

        assert_equal 1, result[ :items ][ 0 ][ :quantity ]
        assert_equal 1, result[ :items ][ 1 ][ :quantity ]
      end

      def test_array_objects_with_as
        builder = build_schema do
          item as: :items, array: true do
            name String
          end
        end

        result = builder.build do
          item { name 'one' }
          item { name 'two' }
        end

        assert_equal 2, result[ :items ].length
        assert_nil result[ :item ]
      end
    end

  end
end
