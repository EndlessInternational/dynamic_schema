require_relative '../../test_helper'

module StructTests
  module MultipleTypes

    class ArrayTest < Minitest::Test

      def test_with_mixed_hash_and_boolean
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            name String
          end
        end

        instance = struct_class.build( items: [
          { name: 'first' },
          true,
          { name: 'second' },
          false
        ] )

        assert_equal 4, instance.items.length
        assert_equal 'first', instance.items[ 0 ].name
        assert_equal true, instance.items[ 1 ]
        assert_equal 'second', instance.items[ 2 ].name
        assert_equal false, instance.items[ 3 ]
      end

      def test_to_h_with_mixed_array
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build( items: [
          { value: 1 },
          true,
          { value: 2 },
          false
        ] )
        result = instance.to_h

        assert_equal 4, result[ :items ].length
        assert_equal( { value: 1 }, result[ :items ][ 0 ] )
        assert_equal true, result[ :items ][ 1 ]
        assert_equal( { value: 2 }, result[ :items ][ 2 ] )
        assert_equal false, result[ :items ][ 3 ]
      end

      def test_without_object_type
        struct_class = DynamicSchema::Struct.define do
          items [ String, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build( items: [
          { value: 1 },
          'hello',
          true,
          { value: 2 },
          false
        ] )

        assert_equal 5, instance.items.length
        assert_equal 1, instance.items[ 0 ].value
        assert_equal 'hello', instance.items[ 1 ]
        assert_equal true, instance.items[ 2 ]
        assert_equal 2, instance.items[ 3 ].value
        assert_equal false, instance.items[ 4 ]
      end

      def test_validation
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build( items: [ { value: 1 }, true, false ] )

        assert instance.valid?
      end

      def test_with_nested_multiple_types
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( items: [
          { nested: { value: 'deep' } },
          true,
          { nested: false }
        ] )

        assert_equal 3, instance.items.length
        assert_equal 'deep', instance.items[ 0 ].nested.value
        assert_equal true, instance.items[ 1 ]
        assert_equal false, instance.items[ 2 ].nested
      end

      def test_to_h_with_nested_multiple_types
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( items: [
          { nested: { value: 'first' } },
          { nested: true },
          false
        ] )
        result = instance.to_h

        assert_equal 3, result[ :items ].length
        assert_equal( { nested: { value: 'first' } }, result[ :items ][ 0 ] )
        assert_equal( { nested: true }, result[ :items ][ 1 ] )
        assert_equal false, result[ :items ][ 2 ]
      end

      def test_validates_array_with_invalid_type
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build( items: [ { value: 1 }, 'invalid' ] )

        refute instance.valid?
      end

      def test_validates_nested_multiple_types_in_array
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( items: [
          { nested: { value: 123 } },
          true,
          { nested: false }
        ] )

        assert instance.valid?
      end

      def test_invalid_nested_type_in_array
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            nested [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( items: [
          { nested: 'invalid' }
        ] )

        refute instance.valid?
      end

    end

  end
end
