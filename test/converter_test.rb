require_relative 'test_helper'

class ConverterTest < Minitest::Test

  # tests for string to numeric conversion
  module StringToNumeric

    class IntegerConversionTest < Minitest::Test
      def test_converts_valid_string_to_integer
        assert_equal 42, DynamicSchema::Converter.convert( '42', to: Integer )
      end

      def test_returns_nil_for_invalid_string
        assert_nil DynamicSchema::Converter.convert( 'x', to: Integer )
      end

      def test_converts_negative_string_to_integer
        assert_equal( -42, DynamicSchema::Converter.convert( '-42', to: Integer ) )
      end
    end

    class FloatConversionTest < Minitest::Test
      def test_converts_valid_string_to_float
        assert_equal 3.14, DynamicSchema::Converter.convert( '3.14', to: Float )
      end

      def test_returns_nil_for_invalid_string
        assert_nil DynamicSchema::Converter.convert( 'x', to: Float )
      end

      def test_converts_integer_string_to_float
        assert_equal 42.0, DynamicSchema::Converter.convert( '42', to: Float )
      end
    end

  end

  # tests for boolean conversion
  module BooleanConversion

    class TrueClassConversionTest < Minitest::Test
      def test_converts_true_string
        assert_equal true, DynamicSchema::Converter.convert( 'true', to: TrueClass )
      end

      def test_converts_one_to_true
        assert_equal true, DynamicSchema::Converter.convert( 1, to: TrueClass )
      end

      def test_returns_nil_for_false_values
        assert_nil DynamicSchema::Converter.convert( 'no', to: TrueClass )
      end
    end

    class FalseClassConversionTest < Minitest::Test
      def test_converts_false_string
        assert_equal false, DynamicSchema::Converter.convert( 'false', to: FalseClass )
      end

      def test_converts_zero_to_false
        assert_equal false, DynamicSchema::Converter.convert( 0, to: FalseClass )
      end

      def test_returns_nil_for_true_values
        assert_nil DynamicSchema::Converter.convert( 'yes', to: FalseClass )
      end
    end

    class BooleanArrayTypeTest < Minitest::Test
      def test_converts_true_string_with_array_type
        assert_equal true, DynamicSchema::Converter.convert( 'true', to: [ TrueClass, FalseClass ] )
      end

      def test_converts_false_string_with_array_type
        assert_equal false, DynamicSchema::Converter.convert( 'false', to: [ TrueClass, FalseClass ] )
      end

      def test_converts_yes_to_true
        assert_equal true, DynamicSchema::Converter.convert( 'yes', to: [ TrueClass, FalseClass ] )
      end

      def test_converts_no_to_false
        assert_equal false, DynamicSchema::Converter.convert( 'no', to: [ TrueClass, FalseClass ] )
      end

      def test_converts_one_to_true
        assert_equal true, DynamicSchema::Converter.convert( 1, to: [ TrueClass, FalseClass ] )
      end

      def test_converts_zero_to_false
        assert_equal false, DynamicSchema::Converter.convert( 0, to: [ TrueClass, FalseClass ] )
      end

      def test_returns_nil_for_non_coercible_value
        assert_nil DynamicSchema::Converter.convert( 'x', to: [ TrueClass, FalseClass ] )
      end
    end

  end

  # tests for date and time conversion
  module DateTimeConversion

    class DateConversionTest < Minitest::Test
      def test_converts_valid_date_string
        assert_equal Date.new( 2024, 1, 2 ), DynamicSchema::Converter.convert( '2024-01-02', to: Date )
      end
    end

    class TimeConversionTest < Minitest::Test
      def test_converts_valid_time_string
        result = DynamicSchema::Converter.convert( '2024-01-02 03:04:05', to: Time )
        assert_instance_of Time, result
      end
    end

    class URIConversionTest < Minitest::Test
      def test_converts_valid_url_string
        expected = URI.parse( 'http://example.com' )
        assert_equal expected, DynamicSchema::Converter.convert( 'http://example.com', to: URI )
      end
    end

  end

  # tests for string and symbol conversion
  module StringSymbolConversion

    class ToStringTest < Minitest::Test
      def test_converts_integer_to_string
        assert_equal '123', DynamicSchema::Converter.convert( 123, to: String )
      end

      def test_converts_float_to_string
        assert_equal '3.14', DynamicSchema::Converter.convert( 3.14, to: String )
      end
    end

    class ToSymbolTest < Minitest::Test
      def test_converts_string_to_symbol
        assert_equal :abc, DynamicSchema::Converter.convert( 'abc', to: Symbol )
      end

      def test_returns_nil_for_non_symbolizable
        assert_nil DynamicSchema::Converter.convert( 123, to: Symbol )
      end
    end

  end

  # tests for array conversion
  module ArrayConversion

    class ToArrayTest < Minitest::Test
      def test_wraps_single_value_in_array
        assert_equal [ 1 ], DynamicSchema::Converter.convert( 1, to: Array )
      end

      def test_returns_array_unchanged
        assert_equal [ 1, 2 ], DynamicSchema::Converter.convert( [ 1, 2 ], to: Array )
      end

      def test_returns_nil_for_nil
        assert_nil DynamicSchema::Converter.convert( nil, to: Array )
      end
    end

  end

  # tests for multiple type conversion
  module MultipleTypeConversion

    class TypeOrderTest < Minitest::Test
      def test_tries_types_in_order_integer_then_float
        # integer will fail to parse "3.0", but float succeeds
        assert_equal 3.0, DynamicSchema::Converter.convert( '3.0', to: [ Integer, Float ] )
      end

      def test_returns_first_successful_conversion
        # integer succeeds immediately
        assert_equal 7, DynamicSchema::Converter.convert( '7', to: [ Integer, Float ] )
      end

      def test_float_first_for_decimal_strings
        assert_equal 1.23, DynamicSchema::Converter.convert( '1.23', to: [ Float, Integer ] )
      end

      def test_integer_first_falls_back_to_float_for_decimal
        # integer('1.23') fails, then float succeeds
        assert_equal 1.23, DynamicSchema::Converter.convert( '1.23', to: [ Integer, Float ] )
      end
    end

    class TypeMatchingTest < Minitest::Test
      def test_returns_value_unchanged_when_already_matches_type
        assert_equal true, DynamicSchema::Converter.convert( true, to: [ FalseClass, TrueClass ] )
      end

      def test_string_remains_string_if_string_is_target_type
        assert_equal '42', DynamicSchema::Converter.convert( '42', to: [ String, Integer ] )
      end
    end

  end

  # tests for fallback block
  module FallbackBlock

    class BlockFallbackTest < Minitest::Test
      def test_yields_block_when_no_types_match
        result = DynamicSchema::Converter.convert( 'x', to: [ Integer, Float ] ) { | v | v.to_s }
        assert_equal 'x', result
      end

      def test_yields_block_for_unknown_type
        klass = Class.new
        result = DynamicSchema::Converter.convert( 'x', to: klass ) { | v | v.to_s.reverse }
        assert_equal 'x', result
      end
    end

  end

  # tests for custom converter registration
  module CustomConverter

    class RegistrationTest < Minitest::Test
      def test_registers_and_uses_custom_converter
        custom_class = Class.new do
          attr_reader :value
          def initialize( value )
            @value = value
          end
        end

        DynamicSchema::Converter.register_converter( custom_class ) do | value |
          custom_class.new( value.to_s.upcase )
        end

        result = DynamicSchema::Converter.convert( 'hello', to: custom_class )
        assert_instance_of custom_class, result
        assert_equal 'HELLO', result.value
      end
    end

  end

end
