require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class ArrayTest < Minitest::Test
      include TestHelper

      def test_with_mixed_values
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            name String
          end
        end

        result = builder.build do
          items true
          items( { name: 'first' } )
          items false
          items( { name: 'second' } )
        end

        assert_equal 4, result[ :items ].length
        assert_equal true, result[ :items ][ 0 ]
        assert_equal 'first', result[ :items ][ 1 ][ :name ]
        assert_equal false, result[ :items ][ 2 ]
        assert_equal 'second', result[ :items ][ 3 ][ :name ]
      end

      def test_with_block_for_objects
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        result = builder.build do
          items do
            value 42
          end
          items do
            value 100
          end
        end

        assert_equal 2, result[ :items ].length
        assert_equal 42, result[ :items ][ 0 ][ :value ]
        assert_equal 100, result[ :items ][ 1 ][ :value ]
      end

      def test_with_custom_class_no_object
        builder = build_schema do
          items [ String, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        result = builder.build do
          items( { value: 1 } )
          items true
          items 'hello'
          items false
        end

        assert_equal 4, result[ :items ].length
        assert_equal 1, result[ :items ][ 0 ][ :value ]
        assert_equal true, result[ :items ][ 1 ]
        assert_equal 'hello', result[ :items ][ 2 ]
        assert_equal false, result[ :items ][ 3 ]
      end

      def test_array_with_nested_multiple_types
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          items do
            nested do
              value 'deep'
            end
          end
          items true
          items do
            nested false
          end
        end

        assert_equal 3, result[ :items ].length
        assert_equal 'deep', result[ :items ][ 0 ][ :nested ][ :value ]
        assert_equal true, result[ :items ][ 1 ]
        assert_equal false, result[ :items ][ 2 ][ :nested ]
      end

      def test_array_with_nested_multiple_types_via_hash
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          items( { nested: { value: 'first' } } )
          items( { nested: true } )
          items false
        end

        assert_equal 3, result[ :items ].length
        assert_equal 'first', result[ :items ][ 0 ][ :nested ][ :value ]
        assert_equal true, result[ :items ][ 1 ][ :nested ]
        assert_equal false, result[ :items ][ 2 ]
      end

      def test_validates_array_with_mixed_types
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        result = builder.build do
          items( { value: 1 } )
          items true
          items( { value: 2 } )
        end

        assert builder.valid?( result )
      end

      def test_validates_array_with_invalid_type
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        result = builder.build do
          items( { value: 1 } )
          items 'invalid'
        end

        refute builder.valid?( result )
      end

    end

  end
end
