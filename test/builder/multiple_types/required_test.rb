require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class RequiredTest < Minitest::Test
      include TestHelper

      def test_raises_when_missing
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ], required: true do
            name String
          end
        end

        error = assert_raises DynamicSchema::RequiredOptionError do
          builder.build! {}
        end

        assert_equal :data, error.key
      end

      def test_passes_with_boolean_value
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ], required: true do
            name String
          end
        end

        result = builder.build! do
          data true
        end

        assert_equal true, result[ :data ]
      end

      def test_passes_with_object_value
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ], required: true do
            name String
          end
        end

        result = builder.build! do
          data do
            name 'test'
          end
        end

        assert_equal 'test', result[ :data ][ :name ]
      end

    end

  end
end
