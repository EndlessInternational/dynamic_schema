require_relative '../test_helper'

module Builder

  class ValuesTest < Minitest::Test
    include TestHelper

    def test_defines_typeless_value
      builder = build_schema do
        api_key
      end

      result = builder.build do
        api_key 'secret-key'
      end

      assert_equal 'secret-key', result[ :api_key ]
    end

    def test_defines_typed_value
      builder = build_schema do
        count Integer
      end

      result = builder.build do
        count 42
      end

      assert_equal 42, result[ :count ]
    end

    def test_allows_nil_for_typeless_value
      builder = build_schema do
        optional_param
      end

      result = builder.build do
        optional_param nil
      end

      assert_nil result[ :optional_param ]
    end

    def test_last_value_takes_precedence
      builder = build_schema do
        param String
      end

      result = builder.build do
        param 'first value'
        param 'second value'
      end

      assert_equal 'second value', result[ :param ]
    end

    def test_value_not_present_when_not_set
      builder = build_schema do
        optional String
      end

      result = builder.build {}
      assert_nil result[ :optional ]
    end

    def test_multiple_values
      builder = build_schema do
        name String
        age Integer
        active [ TrueClass, FalseClass ]
      end

      result = builder.build do
        name 'Alice'
        age 30
        active true
      end

      assert_equal 'Alice', result[ :name ]
      assert_equal 30, result[ :age ]
      assert_equal true, result[ :active ]
    end
  end

end
