require_relative '../../../test_helper'

module Builder
  module Options
    module Normalize

      class MultipleTypesTest < Minitest::Test
        include TestHelper

        def test_normalizes_scalar_in_multiple_types
          builder = build_schema do
            value [ Object, String ], normalize: ->( v ) { v.is_a?( String ) ? v.upcase : v } do
              name String
            end
          end

          result = builder.build { value 'test' }
          assert_equal 'TEST', result[ :value ]
        end

        def test_normalizes_object_in_multiple_types
          builder = build_schema do
            value [ Object, String ], normalize: ->( v ) { v.respond_to?( :to_h ) ? v.to_h : v } do
              name String
            end
          end

          result = builder.build { value { name 'Alice' } }
          assert_equal( { name: 'Alice' }, result[ :value ] )
        end

        def test_normalizes_each_item_in_multiple_types_array
          builder = build_schema do
            items [ Object, Integer ], array: true, normalize: ->( v ) {
              v.respond_to?( :to_h ) ? v.to_h : v * 2
            } do
              name String
            end
          end

          result = builder.build do
            items 5
            items { name 'test' }
          end

          assert_equal [ 10, { name: 'test' } ], result[ :items ]
        end
      end

    end
  end
end
