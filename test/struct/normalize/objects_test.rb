require_relative '../../test_helper'

module StructTests
  module Normalize

    class ObjectsTest < Minitest::Test
      include TestHelper

      def test_normalizes_nested_object
        custom_class = ::Struct.new( :name )
        klass = DynamicSchema::Struct.define do
          user normalize: ->( v ) { custom_class.new( v.name ) } do
            name String
          end
        end

        struct = klass.build( user: { name: 'Alice' } )
        assert_instance_of custom_class, struct.user
        assert_equal 'Alice', struct.user.name
      end

      def test_normalizes_each_item_in_object_array
        custom_class = ::Struct.new( :name )
        klass = DynamicSchema::Struct.define do
          users array: true, normalize: ->( v ) { custom_class.new( v.name ) } do
            name String
          end
        end

        struct = klass.build( users: [ { name: 'Alice' }, { name: 'Bob' } ] )
        assert_equal 2, struct.users.length
        assert_instance_of custom_class, struct.users[ 0 ]
        assert_equal 'Alice', struct.users[ 0 ].name
        assert_equal 'Bob', struct.users[ 1 ].name
      end
    end

  end
end
