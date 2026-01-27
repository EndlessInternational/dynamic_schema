require_relative '../../test_helper'
require 'ostruct'

module Builder
  module MultipleTypes

    class CustomTypesTest < Minitest::Test
      include TestHelper

      def test_custom_class_instance_passes_through
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
        end

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        result = builder.build do
          data instance
        end

        assert_equal instance, result[ :data ]
        assert_equal 'test', result[ :data ].name
      end

      def test_hash_subclass_treated_as_hash
        hash_subclass = Class.new( Hash )

        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        input = hash_subclass.new
        input[ :value ] = 'from subclass'

        result = builder.build do
          data input
        end

        assert_equal 'from subclass', result[ :data ][ :value ]
      end

      def test_custom_class_with_to_h_converted_by_to_h
        # builder.build returns to_h which converts objects with to_h methods
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
          def to_h
            { name: @name }
          end
        end

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        result = builder.build do
          data instance
        end

        # to_h converts the custom object to its hash representation
        assert_equal( { name: 'test' }, result[ :data ] )
      end

      def test_custom_class_without_to_h_passes_through
        custom_class = Class.new do
          attr_reader :name
          def initialize( name )
            @name = name
          end
        end

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new( 'test' )
        result = builder.build do
          data instance
        end

        # without to_h, the object passes through unchanged
        assert_kind_of custom_class, result[ :data ]
        assert_equal 'test', result[ :data ].name
      end

      def test_open_struct_converted_by_to_h
        # OpenStruct has to_h, so builder converts it
        builder = build_schema do
          data [ Object, OpenStruct, TrueClass, FalseClass ] do
            value String
          end
        end

        input = OpenStruct.new( value: 'from ostruct' )
        result = builder.build do
          data input
        end

        # to_h converts the OpenStruct to a hash
        assert_kind_of Hash, result[ :data ]
        assert_equal 'from ostruct', result[ :data ][ :value ]
      end

      def test_hash_takes_precedence_over_custom_class
        custom_class = Class.new do
          attr_reader :value
          def initialize( value = nil )
            @value = value
          end
        end

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            nested_value String
          end
        end

        result = builder.build do
          data( { nested_value: 'from hash' } )
        end

        assert_equal 'from hash', result[ :data ][ :nested_value ]
        refute_kind_of custom_class, result[ :data ]
      end

      def test_dynamic_schema_struct_as_type
        # DynamicSchema::Struct has to_h, so it gets converted
        inner_struct = DynamicSchema::Struct.define do
          name String
        end

        builder = build_schema do
          data [ Object, inner_struct, TrueClass, FalseClass ] do
            different_field Integer
          end
        end

        struct_instance = inner_struct.build( name: 'from struct' )
        result = builder.build do
          data struct_instance
        end

        # to_h converts the struct to its hash representation
        assert_kind_of Hash, result[ :data ]
        assert_equal 'from struct', result[ :data ][ :name ]
      end

      def test_hash_uses_block_schema_not_custom_struct
        inner_struct = DynamicSchema::Struct.define do
          name String
        end

        builder = build_schema do
          data [ Object, inner_struct, TrueClass, FalseClass ] do
            different_field Integer
          end
        end

        result = builder.build do
          data( { different_field: 42 } )
        end

        assert_equal 42, result[ :data ][ :different_field ]
      end

      def test_array_with_mixed_custom_and_hash
        custom_class = Class.new do
          attr_reader :id
          def initialize( id )
            @id = id
          end
        end

        builder = build_schema do
          items [ Object, custom_class, TrueClass, FalseClass ], array: true do
            value String
          end
        end

        instance = custom_class.new( 123 )
        result = builder.build do
          items( { value: 'hash item' } )
          items instance
          items true
        end

        assert_equal 3, result[ :items ].length
        assert_equal 'hash item', result[ :items ][ 0 ][ :value ]
        assert_kind_of custom_class, result[ :items ][ 1 ]
        assert_equal 123, result[ :items ][ 1 ].id
        assert_equal true, result[ :items ][ 2 ]
      end

      def test_nested_with_custom_type_at_inner_level
        custom_class = Class.new do
          attr_reader :label
          def initialize( label )
            @label = label
          end
        end

        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, custom_class, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = custom_class.new( 'custom' )
        result = builder.build do
          outer do
            inner instance
          end
        end

        assert_kind_of custom_class, result[ :outer ][ :inner ]
        assert_equal 'custom', result[ :outer ][ :inner ].label
      end

      def test_validates_custom_class_type
        custom_class = Class.new

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = custom_class.new
        result = builder.build do
          data instance
        end

        assert builder.valid?( result )
      end

      def test_invalid_type_not_in_list
        custom_class = Class.new
        other_class = Class.new

        builder = build_schema do
          data [ Object, custom_class, TrueClass, FalseClass ] do
            value String
          end
        end

        other_instance = other_class.new
        result = builder.build do
          data other_instance
        end

        refute builder.valid?( result )
      end

    end

  end
end
