require_relative '../../test_helper'

module StructTests
  module Normalize

    class MultipleTypesTest < Minitest::Test
      include TestHelper

      def test_normalizes_scalar_in_multiple_types
        klass = DynamicSchema::Struct.define do
          value [ Object, String ], normalize: ->( v ) { v.is_a?( String ) ? v.upcase : v } do
            name String
          end
        end

        struct = klass.build( value: 'test' )
        assert_equal 'TEST', struct.value
      end

      def test_normalizes_object_in_multiple_types
        custom_class = ::Struct.new( :name )
        klass = DynamicSchema::Struct.define do
          value [ Object, String ], normalize: ->( v ) {
            v.respond_to?( :name ) ? custom_class.new( v.name ) : v
          } do
            name String
          end
        end

        struct = klass.build( value: { name: 'Alice' } )
        assert_instance_of custom_class, struct.value
        assert_equal 'Alice', struct.value.name
      end

      def test_normalizes_each_item_in_multiple_types_array
        klass = DynamicSchema::Struct.define do
          items [ Object, Integer ], array: true, normalize: ->( v ) {
            v.respond_to?( :to_h ) ? v.to_h : v * 2
          } do
            name String
          end
        end

        struct = klass.build( items: [ 5, { name: 'test' } ] )
        assert_equal [ 10, { name: 'test' } ], struct.items
      end
    end

  end
end
