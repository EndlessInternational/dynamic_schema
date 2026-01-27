require_relative '../test_helper'

module Receiver
  module Coercion

    class NumericCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_string_to_integer
        schema = { count: { type: Integer } }
        receiver = build_receiver( schema: schema )

        receiver.count '42'

        result = receiver.to_h
        assert_equal 42, result[ :count ]
        assert_instance_of Integer, result[ :count ]
      end

      def test_coerces_string_to_float
        schema = { price: { type: Float } }
        receiver = build_receiver( schema: schema )

        receiver.price '19.99'

        result = receiver.to_h
        assert_equal 19.99, result[ :price ]
        assert_instance_of Float, result[ :price ]
      end
    end

    class DateTimeCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_string_to_date
        schema = { start_date: { type: Date } }
        receiver = build_receiver( schema: schema )

        receiver.start_date '2023-01-01'

        result = receiver.to_h
        assert_equal Date.new( 2023, 1, 1 ), result[ :start_date ]
        assert_instance_of Date, result[ :start_date ]
      end

      def test_coerces_string_to_time
        schema = { start_time: { type: Time } }
        receiver = build_receiver( schema: schema )

        receiver.start_time '2023-01-01 12:34:56'

        result = receiver.to_h
        assert_equal Time.parse( '2023-01-01 12:34:56' ), result[ :start_time ]
        assert_instance_of Time, result[ :start_time ]
      end

      def test_coerces_string_to_uri
        schema = { website: { type: URI } }
        receiver = build_receiver( schema: schema )

        receiver.website 'http://example.com'

        result = receiver.to_h
        assert_equal URI.parse( 'http://example.com' ), result[ :website ]
        assert_instance_of URI::HTTP, result[ :website ]
      end
    end

    class BooleanCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_yes_to_true
        schema = { enabled: { type: [ TrueClass, FalseClass ] } }
        receiver = build_receiver( schema: schema )

        receiver.enabled 'yes'

        result = receiver.to_h
        assert_equal true, result[ :enabled ]
      end

      def test_coerces_true_string_to_true
        schema = { enabled: { type: [ TrueClass, FalseClass ] } }
        receiver = build_receiver( schema: schema )

        receiver.enabled 'true'

        result = receiver.to_h
        assert_equal true, result[ :enabled ]
      end

      def test_coerces_no_to_false
        schema = { disabled: { type: [ TrueClass, FalseClass ] } }
        receiver = build_receiver( schema: schema )

        receiver.disabled 'no'

        result = receiver.to_h
        assert_equal false, result[ :disabled ]
      end

      def test_coerces_false_string_to_false
        schema = { disabled: { type: [ TrueClass, FalseClass ] } }
        receiver = build_receiver( schema: schema )

        receiver.disabled 'false'

        result = receiver.to_h
        assert_equal false, result[ :disabled ]
      end
    end

    class SymbolCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_string_to_symbol
        schema = { strategy: { type: Symbol } }
        receiver = build_receiver( schema: schema )

        receiver.strategy 'fight'

        result = receiver.to_h
        assert_instance_of Symbol, result[ :strategy ]
        assert_equal :fight, result[ :strategy ]
      end
    end

    class ArrayCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_array_elements
        schema = { numbers: { type: Integer, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.numbers [ '1', '2', '3' ]

        result = receiver.to_h
        assert_equal [ 1, 2, 3 ], result[ :numbers ]
      end
    end

    class NestedCoercionTest < Minitest::Test
      include TestHelper

      def test_coerces_nested_values
        schema = {
          user: {
            type: Object,
            schema: {
              age: { type: Integer }
            }
          }
        }
        receiver = build_receiver( schema: schema )

        receiver.user do
          age '30'
        end

        result = receiver.to_h
        assert_equal 30, result[ :user ][ :age ]
        assert_instance_of Integer, result[ :user ][ :age ]
      end
    end

    class MultipleTypeCoercionTest < Minitest::Test
      include TestHelper

      def test_keeps_value_when_already_matching_type
        schema = { flexible: { type: [ Integer, String ] } }
        receiver = build_receiver( schema: schema )

        receiver.flexible '42'

        result = receiver.to_h
        # string is matched first
        assert_instance_of String, result[ :flexible ]
        assert_equal '42', result[ :flexible ]
      end

      def test_integer_value_stays_integer
        schema = { flexible: { type: [ Integer, String ] } }
        receiver = build_receiver( schema: schema )

        receiver.flexible 42

        result = receiver.to_h
        assert_instance_of Integer, result[ :flexible ]
        assert_equal 42, result[ :flexible ]
      end
    end

    class CustomConverterTest < Minitest::Test
      include TestHelper

      def test_custom_converter_in_builder
        upcase_string = Class.new( String ) do
          def initialize( string )
            super( string.upcase )
          end
        end

        builder = DynamicSchema::Builder.new
        builder.register_converter( upcase_string ) { | v | upcase_string.new( v ) }
        builder.define { name upcase_string }

        result = builder.build! { name 'john doe' }

        assert_instance_of upcase_string, result[ :name ]
        assert_equal 'JOHN DOE', result[ :name ].to_s
      end
    end

  end

end
