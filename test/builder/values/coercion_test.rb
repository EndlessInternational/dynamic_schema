require_relative '../../test_helper'

module Builder
  module Values

    class CoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_string_to_integer
        builder = build_schema do
          count Integer
        end

        result = builder.build { count '42' }
        assert_equal 42, result[ :count ]
        assert_instance_of Integer, result[ :count ]
      end

      def test_coerces_string_to_float
        builder = build_schema do
          price Float
        end

        result = builder.build { price '19.99' }
        assert_equal 19.99, result[ :price ]
        assert_instance_of Float, result[ :price ]
      end

      def test_coerces_string_to_symbol
        builder = build_schema do
          status Symbol
        end

        result = builder.build { status 'active' }
        assert_equal :active, result[ :status ]
        assert_instance_of Symbol, result[ :status ]
      end

      def test_coerces_string_to_boolean_true
        builder = build_schema do
          enabled [ TrueClass, FalseClass ]
        end

        result = builder.build { enabled 'yes' }
        assert_equal true, result[ :enabled ]
      end

      def test_coerces_string_to_boolean_false
        builder = build_schema do
          disabled [ TrueClass, FalseClass ]
        end

        result = builder.build { disabled 'no' }
        assert_equal false, result[ :disabled ]
      end

      def test_coerces_integer_to_boolean
        builder = build_schema do
          flag [ TrueClass, FalseClass ]
        end

        result = builder.build { flag 1 }
        assert_equal true, result[ :flag ]

        result = builder.build { flag 0 }
        assert_equal false, result[ :flag ]
      end

      def test_coerces_string_to_date
        builder = build_schema do
          start_date Date
        end

        result = builder.build { start_date '2024-01-15' }
        assert_equal Date.new( 2024, 1, 15 ), result[ :start_date ]
      end

      def test_coerces_string_to_time
        builder = build_schema do
          timestamp Time
        end

        result = builder.build { timestamp '2024-01-15 12:30:00' }
        assert_instance_of Time, result[ :timestamp ]
      end

      def test_coerces_string_to_uri
        builder = build_schema do
          website URI
        end

        result = builder.build { website 'http://example.com' }
        assert_equal URI.parse( 'http://example.com' ), result[ :website ]
      end

      def test_coerces_integer_to_string
        builder = build_schema do
          value String
        end

        result = builder.build { value 123 }
        assert_equal '123', result[ :value ]
      end
    end

  end
end
