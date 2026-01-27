require_relative '../../../test_helper'

module Builder
  module Options
    module Normalize

      class ArrayTest < Minitest::Test
        include TestHelper

        def test_normalizes_each_item_in_array
          builder = build_schema do
            tags String, array: true, normalize: ->( v ) { v.upcase }
          end

          result = builder.build { tags [ 'one', 'two', 'three' ] }
          assert_equal [ 'ONE', 'TWO', 'THREE' ], result[ :tags ]
        end

        def test_normalizes_singular_value_on_array_attribute
          builder = build_schema do
            tags String, array: true, normalize: ->( v ) { v.upcase }
          end

          result = builder.build { tags 'single' }
          assert_equal [ 'SINGLE' ], result[ :tags ]
        end

        def test_normalizes_appended_array_items
          builder = build_schema do
            tags String, array: true, normalize: ->( v ) { v.upcase }
          end

          result = builder.build do
            tags 'one'
            tags 'two'
          end

          assert_equal [ 'ONE', 'TWO' ], result[ :tags ]
        end

        def test_normalize_receives_value_not_array
          received_values = []
          builder = build_schema do
            numbers Integer, array: true, normalize: ->( v ) {
              received_values << v
              v
            }
          end

          builder.build { numbers [ 1, 2, 3 ] }
          assert_equal [ 1, 2, 3 ], received_values
        end

        def test_normalize_array_with_hash_initialization
          builder = build_schema do
            tags String, array: true, normalize: ->( v ) { v.upcase }
          end

          result = builder.build( { tags: [ 'one', 'two' ] } )
          assert_equal [ 'ONE', 'TWO' ], result[ :tags ]
        end
      end

    end
  end
end
