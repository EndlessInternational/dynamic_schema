require_relative '../../test_helper'
require 'ostruct'

module StructTests
  module MultipleTypes

    class CustomTypesTest < Minitest::Test

      def test_custom_class_instance_passes_through
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        struct = struct_class.build( data: instance )

        assert_kind_of custom_class, struct.data
        assert_equal 'test', struct.data.name
      end

      def test_hash_subclass_treated_as_hash
        hash_subclass = Class.new( Hash )

        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        input = hash_subclass.new
        input[ :value ] = 'from subclass'

        struct = struct_class.build( data: input )

        assert_respond_to struct.data, :value
        assert_equal 'from subclass', struct.data.value
      end

      def test_custom_class_with_to_h_passes_through
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
          def to_h
            { name: @name }
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        struct = struct_class.build( data: instance )

        assert_kind_of custom_class, struct.data
        assert_equal 'test', struct.data.name
      end

      def test_open_struct_treated_as_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, OpenStruct, TrueClass, FalseClass ] do
            value String
          end
        end

        input = OpenStruct.new( value: 'from ostruct' )
        struct = struct_class.build( data: input )

        assert_kind_of OpenStruct, struct.data
        assert_equal 'from ostruct', struct.data.value
      end

      def test_hash_takes_precedence_over_custom_class
        custom_class = Class.new do
          attr_reader :value
          def initialize( value = nil )
            @value = value
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            nested_value String
          end
        end

        struct = struct_class.build( data: { nested_value: 'from hash' } )

        assert_equal 'from hash', struct.data.nested_value
        refute_kind_of custom_class, struct.data
      end

      def test_dynamic_schema_struct_as_type
        inner_struct = DynamicSchema::Struct.define do
          name String
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, inner_struct, TrueClass, FalseClass ] do
            different_field Integer
          end
        end

        struct_instance = inner_struct.build( name: 'from struct' )
        struct = struct_class.build( data: struct_instance )

        assert_kind_of inner_struct, struct.data
        assert_equal 'from struct', struct.data.name
      end

      def test_hash_uses_block_schema_not_custom_struct
        inner_struct = DynamicSchema::Struct.define do
          name String
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, inner_struct, TrueClass, FalseClass ] do
            different_field Integer
          end
        end

        struct = struct_class.build( data: { different_field: 42 } )

        assert_equal 42, struct.data.different_field
      end

      def test_array_with_mixed_custom_and_hash
        custom_class = Class.new do
          attr_reader :id
          def initialize( id )
            @id = id
          end
        end

        struct_class = DynamicSchema::Struct.define do
          items [ Object, custom_class, TrueClass, FalseClass ], array: true do
            value String
          end
        end

        instance = custom_class.new( 123 )
        struct = struct_class.build( items: [
          { value: 'hash item' },
          instance,
          true
        ] )

        assert_equal 3, struct.items.length
        assert_equal 'hash item', struct.items[ 0 ].value
        assert_kind_of custom_class, struct.items[ 1 ]
        assert_equal 123, struct.items[ 1 ].id
        assert_equal true, struct.items[ 2 ]
      end

      def test_nested_with_custom_type_at_inner_level
        custom_class = Class.new do
          attr_reader :label
          def initialize( label )
            @label = label
          end
        end

        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, custom_class, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = custom_class.new( 'custom' )
        struct = struct_class.build( outer: { inner: instance } )

        assert_kind_of custom_class, struct.outer.inner
        assert_equal 'custom', struct.outer.inner.label
      end

      def test_to_h_with_custom_class
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
          def to_h
            { custom_name: @name }
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        struct = struct_class.build( data: instance )
        result = struct.to_h

        assert_equal( { custom_name: 'test' }, result[ :data ] )
      end

      def test_to_h_with_custom_class_no_to_h
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        struct = struct_class.build( data: instance )
        result = struct.to_h

        assert_kind_of custom_class, result[ :data ]
      end

      def test_validates_custom_class_type
        custom_class = Class.new

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new
        struct = struct_class.build( data: instance )

        assert struct.valid?
      end

      def test_invalid_type_not_in_list
        custom_class = Class.new
        other_class = Class.new

        struct_class = DynamicSchema::Struct.define do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        other_instance = other_class.new
        struct = struct_class.build( data: other_instance )

        refute struct.valid?
      end

      def test_validates_array_with_custom_class
        custom_class = Class.new

        struct_class = DynamicSchema::Struct.define do
          items [ Object, custom_class, TrueClass, FalseClass ], array: true do
            value String
          end
        end

        instance = custom_class.new
        struct = struct_class.build( items: [
          { value: 'hash' },
          instance,
          true
        ] )

        assert struct.valid?
      end

      def test_invalid_array_element_type
        custom_class = Class.new
        other_class = Class.new

        struct_class = DynamicSchema::Struct.define do
          items [ Object, custom_class, TrueClass, FalseClass ], array: true do
            value String
          end
        end

        other_instance = other_class.new
        struct = struct_class.build( items: [
          { value: 'hash' },
          other_instance
        ] )

        refute struct.valid?
      end

    end

  end
end
