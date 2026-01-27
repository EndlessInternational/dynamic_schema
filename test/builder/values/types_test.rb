require_relative '../../test_helper'

module Builder
  module Values

    class TypesTest < Minitest::Test
      include TestHelper

      def test_string_type
        builder = build_schema do
          name String
        end

        result = builder.build { name 'Alice' }
        assert_equal 'Alice', result[ :name ]
      end

      def test_integer_type
        builder = build_schema do
          age Integer
        end

        result = builder.build { age 30 }
        assert_equal 30, result[ :age ]
      end

      def test_float_type
        builder = build_schema do
          price Float
        end

        result = builder.build { price 19.99 }
        assert_equal 19.99, result[ :price ]
      end

      def test_symbol_type
        builder = build_schema do
          status Symbol
        end

        result = builder.build { status :active }
        assert_equal :active, result[ :status ]
      end

      def test_boolean_type_true
        builder = build_schema do
          enabled [ TrueClass, FalseClass ]
        end

        result = builder.build { enabled true }
        assert_equal true, result[ :enabled ]
      end

      def test_boolean_type_false
        builder = build_schema do
          enabled [ TrueClass, FalseClass ]
        end

        result = builder.build { enabled false }
        assert_equal false, result[ :enabled ]
      end

      def test_multiple_types
        builder = build_schema do
          flexible [ Integer, String ]
        end

        result = builder.build { flexible 42 }
        assert_equal 42, result[ :flexible ]

        result = builder.build { flexible 'text' }
        assert_equal 'text', result[ :flexible ]
      end

      def test_date_type
        builder = build_schema do
          start_date Date
        end

        result = builder.build { start_date Date.new( 2024, 1, 15 ) }
        assert_equal Date.new( 2024, 1, 15 ), result[ :start_date ]
      end

      def test_time_type
        builder = build_schema do
          timestamp Time
        end

        time = Time.now
        result = builder.build { timestamp time }
        assert_equal time, result[ :timestamp ]
      end

      def test_uri_type
        builder = build_schema do
          website URI
        end

        uri = URI.parse( 'http://example.com' )
        result = builder.build { website uri }
        assert_equal uri, result[ :website ]
      end
    end

  end
end
