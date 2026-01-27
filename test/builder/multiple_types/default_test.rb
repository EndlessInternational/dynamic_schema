require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class DefaultTest < Minitest::Test
      include TestHelper

      def test_with_default_boolean
        builder = build_schema do
          enabled [ Object, TrueClass, FalseClass ], default: false do
            level Integer
          end
        end

        result = builder.build {}

        assert_equal false, result[ :enabled ]
      end

      def test_with_default_object
        builder = build_schema do
          config [ Object, TrueClass, FalseClass ], default: { level: 1 } do
            level Integer
          end
        end

        result = builder.build {}

        assert_equal( { level: 1 }, result[ :config ].to_h )
      end

      def test_array_default
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true, default: [] do
            name String
          end
        end

        result = builder.build {}

        assert_equal [], result[ :items ]
      end

    end

  end
end
