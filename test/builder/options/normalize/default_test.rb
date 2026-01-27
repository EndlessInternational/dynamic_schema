require_relative '../../../test_helper'

module Builder
  module Options
    module Normalize

      class DefaultTest < Minitest::Test
        include TestHelper

        def test_normalizes_default_value
          builder = build_schema do
            name String, default: 'default', normalize: ->( v ) { v.upcase }
          end

          result = builder.build {}
          assert_equal 'DEFAULT', result[ :name ]
        end

        def test_normalizes_overridden_default_value
          builder = build_schema do
            name String, default: 'default', normalize: ->( v ) { v.upcase }
          end

          result = builder.build { name 'custom' }
          assert_equal 'CUSTOM', result[ :name ]
        end

        def test_normalizes_default_array_value
          builder = build_schema do
            tags String, array: true, default: [ 'one', 'two' ], normalize: ->( v ) { v.upcase }
          end

          result = builder.build {}
          assert_equal [ 'ONE', 'TWO' ], result[ :tags ]
        end
      end

    end
  end
end
