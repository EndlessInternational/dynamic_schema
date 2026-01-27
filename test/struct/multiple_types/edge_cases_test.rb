require_relative '../../test_helper'

module StructTests
  module MultipleTypes

    class EdgeCasesTest < Minitest::Test

      def test_nil_passes_through
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: nil )

        assert_nil instance.data
      end

      def test_empty_hash_treated_as_object
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String, default: 'default'
          end
        end

        instance = struct_class.build( data: {} )

        assert_respond_to instance.data, :value
        assert_equal 'default', instance.data.value
      end

      def test_subclass_of_listed_type_is_valid
        parent_class = Class.new
        child_class = Class.new( parent_class )

        struct_class = DynamicSchema::Struct.define do
          data [ Object, parent_class, TrueClass, FalseClass ] do
            value String
          end
        end

        child_instance = child_class.new
        instance = struct_class.build( data: child_instance )

        assert instance.valid?
      end

      def test_module_as_type
        test_module = Module.new

        klass = Class.new do
          include test_module
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, test_module, TrueClass, FalseClass ] do
            value String
          end
        end

        module_instance = klass.new
        instance = struct_class.build( data: module_instance )

        assert instance.valid?
      end

      def test_single_element_array_with_block
        struct_class = DynamicSchema::Struct.define do
          data [ Object ] do
            value String
          end
        end

        instance = struct_class.build( data: { value: 'nested' } )

        assert_equal 'nested', instance.data.value
      end

      def test_hash_like_object_not_treated_as_hash
        hash_like = Class.new do
          def []( key )
            :value
          end
          def key?( key )
            true
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, hash_like, TrueClass, FalseClass ] do
            nested String
          end
        end

        hash_like_instance = hash_like.new
        instance = struct_class.build( data: hash_like_instance )

        assert_kind_of hash_like, instance.data
      end

      def test_integer_zero_is_valid_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Integer, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: 0 )

        assert_equal 0, instance.data
        assert instance.valid?
      end

      def test_empty_string_is_valid_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, String, TrueClass, FalseClass ] do
            value Integer
          end
        end

        instance = struct_class.build( data: '' )

        assert_equal '', instance.data
        assert instance.valid?
      end

      def test_empty_array_as_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Array, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: [] )

        assert_equal [], instance.data
      end

      def test_coercion_string_to_integer_in_scalar_types
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Integer, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: '42' )

        assert_equal 42, instance.data
      end

      def test_validates_with_numeric_types
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Integer, Float ] do
            value String
          end
        end

        instance = struct_class.build( data: 3.14 )

        assert instance.valid?
      end

      def test_invalid_with_wrong_numeric_type
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Integer ] do
            value String
          end
        end

        instance = struct_class.build( data: 3.14 )

        refute instance.valid?
      end

      def test_symbol_not_confused_with_hash
        struct_class = DynamicSchema::Struct.define do
          data [ Object, Symbol, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: :my_symbol )

        assert_equal :my_symbol, instance.data
      end

      def test_to_h_with_nil_value
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: nil )
        result = instance.to_h

        refute result.key?( :data )
      end

      def test_to_h_with_empty_hash_value
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: {} )
        result = instance.to_h

        # empty nested object should not appear in to_h
        refute result.key?( :data )
      end

      def test_setter_from_object_to_boolean
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: { value: 'test' } )
        assert_equal 'test', instance.data.value

        instance.data = true
        assert_equal true, instance.data
      end

      def test_setter_from_boolean_to_object
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: false )
        assert_equal false, instance.data

        instance.data = { value: 'changed' }
        assert_equal 'changed', instance.data.value
      end

      def test_array_with_nil_elements
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value String
          end
        end

        instance = struct_class.build( items: [ { value: 'test' }, nil, true ] )

        assert_equal 3, instance.items.length
        assert_equal 'test', instance.items[ 0 ].value
        assert_nil instance.items[ 1 ]
        assert_equal true, instance.items[ 2 ]
      end

      def test_validates_array_with_nil_elements
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass, NilClass ], array: true do
            value String
          end
        end

        instance = struct_class.build( items: [ nil, true, { value: 'test' } ] )

        assert instance.valid?
      end

    end

  end
end
