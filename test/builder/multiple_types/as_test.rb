require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class AsTest < Minitest::Test
      include TestHelper

      def test_with_as_option_using_object
        builder = build_schema do
          config [ Object, TrueClass, FalseClass ], as: :configuration do
            timeout Integer
          end
        end

        result = builder.build do
          config do
            timeout 30
          end
        end

        assert_equal 30, result[ :configuration ][ :timeout ]
      end

      def test_with_as_option_using_boolean
        builder = build_schema do
          config [ Object, TrueClass, FalseClass ], as: :configuration do
            timeout Integer
          end
        end

        result = builder.build do
          config true
        end

        assert_equal true, result[ :configuration ]
      end

      def test_array_with_as_option
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true, as: :elements do
            name String
          end
        end

        result = builder.build do
          items true
          items( { name: 'test' } )
        end

        assert_equal 2, result[ :elements ].length
        assert_equal true, result[ :elements ][ 0 ]
        assert_equal 'test', result[ :elements ][ 1 ][ :name ]
      end

    end

  end
end
