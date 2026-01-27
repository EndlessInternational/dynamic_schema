require_relative '../../../test_helper'

module Builder
  module Options
    module Normalize

      class ObjectsTest < Minitest::Test
        include TestHelper

        def test_normalizes_nested_object
          builder = build_schema do
            user normalize: ->( v ) { v } do
              name String
            end
          end

          result = builder.build { user { name 'Alice' } }
          assert_equal 'Alice', result[ :user ][ :name ]
        end

        def test_normalizes_nested_object_to_custom_type
          custom_class = Class.new do
            attr_reader :name
            def initialize( name )
              @name = name
            end
          end
          builder = build_schema do
            user normalize: ->( v ) { custom_class.new( v.to_h[ :name ] ) } do
              name String
            end
          end

          result = builder.build { user { name 'Alice' } }
          assert_instance_of custom_class, result[ :user ]
          assert_equal 'Alice', result[ :user ].name
        end

        def test_normalizes_each_item_in_object_array
          builder = build_schema do
            users array: true, normalize: ->( v ) { v.to_h } do
              name String
            end
          end

          result = builder.build do
            users { name 'Alice' }
            users { name 'Bob' }
          end

          assert_equal [ { name: 'Alice' }, { name: 'Bob' } ], result[ :users ]
        end
      end

    end
  end
end
