require_relative '../../test_helper'

module Builder
  module Options

    class ArrayTest < Minitest::Test
      include TestHelper

      def test_wraps_single_value_in_array
        builder = build_schema do
          tags String, array: true
        end

        result = builder.build { tags 'important' }
        assert_equal [ 'important' ], result[ :tags ]
      end

      def test_accepts_array_value
        builder = build_schema do
          tags String, array: true
        end

        result = builder.build { tags [ 'one', 'two', 'three' ] }
        assert_equal [ 'one', 'two', 'three' ], result[ :tags ]
      end

      def test_coerces_array_elements
        builder = build_schema do
          numbers Integer, array: true
        end

        result = builder.build { numbers [ '1', '2', '3' ] }
        assert_equal [ 1, 2, 3 ], result[ :numbers ]
      end

      def test_appends_multiple_calls
        builder = build_schema do
          tags String, array: true
        end

        result = builder.build do
          tags 'one'
          tags 'two'
        end

        assert_equal [ 'one', 'two' ], result[ :tags ]
      end
    end

    class ArrayTypesTest < Minitest::Test
      include TestHelper

      def test_string_array
        builder = build_schema do
          names String, array: true
        end

        result = builder.build { names [ 'Alice', 'Bob' ] }
        assert_equal [ 'Alice', 'Bob' ], result[ :names ]
      end

      def test_integer_array
        builder = build_schema do
          counts Integer, array: true
        end

        result = builder.build { counts [ 1, 2, 3 ] }
        assert_equal [ 1, 2, 3 ], result[ :counts ]
      end

      def test_float_array
        builder = build_schema do
          prices Float, array: true
        end

        result = builder.build { prices [ 1.1, 2.2, 3.3 ] }
        assert_equal [ 1.1, 2.2, 3.3 ], result[ :prices ]
      end

      def test_boolean_array
        builder = build_schema do
          flags [ TrueClass, FalseClass ], array: true
        end

        result = builder.build { flags [ true, false, true ] }
        assert_equal [ true, false, true ], result[ :flags ]
      end

      def test_mixed_array_without_type
        builder = build_schema do
          mixed array: true
        end

        result = builder.build { mixed [ 1, 'two', 3.0, true ] }
        assert_equal [ 1, 'two', 3.0, true ], result[ :mixed ]
      end
    end

    class ArrayValidationTest < Minitest::Test
      include TestHelper

      def test_raises_for_incompatible_array_type
        builder = build_schema do
          numbers Integer, array: true
        end

        assert_raises DynamicSchema::IncompatibleTypeError do
          builder.build! { numbers [ 1, 'not-a-number', 3 ] }
        end
      end
    end

  end
end
