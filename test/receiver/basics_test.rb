require_relative '../test_helper'

module Receiver

  # tests for receiver initialization
  class InitializationTest < Minitest::Test
    include TestHelper

    def test_accepts_nil_values
      schema = { name: { type: String } }
      receiver = build_receiver( nil, schema: schema )

      assert receiver.is_a?( DynamicSchema::Receiver::Object )
    end

    def test_accepts_hash_values
      schema = { name: { type: String } }
      receiver = build_receiver( { name: 'Alice' }, schema: schema )

      result = receiver.to_h
      assert_equal 'Alice', result[ :name ]
    end

    def test_raises_for_invalid_values_type
      schema = { name: { type: String } }

      assert_raises ArgumentError do
        DynamicSchema::Receiver::Object.new(
          'not-a-hash',
          schema: schema,
          converter: DynamicSchema::Converter
        )
      end
    end

    def test_initializes_with_defaults_enabled
      schema = { version: { type: String, default: '1.0' } }
      receiver = build_receiver( schema: schema, defaults: true )

      result = receiver.to_h
      assert_equal '1.0', result[ :version ]
    end

    def test_initializes_with_defaults_disabled
      schema = { version: { type: String, default: '1.0' } }
      receiver = build_receiver( schema: schema, defaults: false )

      result = receiver.to_h
      assert_nil result[ :version ]
    end
  end

  # tests for to_h method
  class ToHashTest < Minitest::Test
    include TestHelper

    def test_returns_hash
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )
      receiver.name 'Alice'

      result = receiver.to_h
      assert_instance_of Hash, result
      assert_equal 'Alice', result[ :name ]
    end

    def test_handles_nested_objects
      schema = {
        user: {
          type: Object,
          schema: {
            name: { type: String }
          }
        }
      }
      receiver = build_receiver( schema: schema )
      receiver.user { name 'Alice' }

      result = receiver.to_h
      assert_instance_of Hash, result[ :user ]
      assert_equal 'Alice', result[ :user ][ :name ]
    end

    def test_handles_arrays
      schema = { tags: { type: String, array: true } }
      receiver = build_receiver( schema: schema )
      receiver.tags [ 'one', 'two' ]

      result = receiver.to_h
      assert_instance_of Array, result[ :tags ]
      assert_equal [ 'one', 'two' ], result[ :tags ]
    end

    def test_handles_nested_arrays
      schema = {
        items: {
          type: Object,
          array: true,
          schema: {
            name: { type: String }
          }
        }
      }
      receiver = build_receiver( schema: schema )
      receiver.items( { name: 'one' } )
      receiver.items( { name: 'two' } )

      result = receiver.to_h
      assert_instance_of Array, result[ :items ]
      assert_equal 2, result[ :items ].length
      assert_equal 'one', result[ :items ][ 0 ][ :name ]
      assert_equal 'two', result[ :items ][ 1 ][ :name ]
    end
  end

  # tests for empty? method
  class EmptyTest < Minitest::Test
    include TestHelper

    def test_empty_when_no_values
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema, defaults: false )

      assert receiver.empty?
    end

    def test_not_empty_when_has_values
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema, defaults: false )
      receiver.name 'Alice'

      refute receiver.empty?
    end

    def test_not_empty_with_defaults
      schema = { version: { type: String, default: '1.0' } }
      receiver = build_receiver( schema: schema, defaults: true )

      refute receiver.empty?
    end
  end

  # tests for respond_to? method
  class RespondToTest < Minitest::Test
    include TestHelper

    def test_responds_to_schema_keys
      schema = {
        name: { type: String },
        age: { type: Integer }
      }
      receiver = build_receiver( schema: schema )

      assert receiver.respond_to?( :name )
      assert receiver.respond_to?( :age )
    end

    def test_does_not_respond_to_unknown_keys
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )

      refute receiver.respond_to?( :unknown )
    end

    def test_responds_to_built_in_methods
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )

      assert receiver.respond_to?( :to_h )
      assert receiver.respond_to?( :empty? )
      assert receiver.respond_to?( :inspect )
    end
  end

  # tests for method_missing
  class MethodMissingTest < Minitest::Test
    include TestHelper

    def test_raises_for_undefined_method
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )

      assert_raises NoMethodError do
        receiver.undefined_method
      end
    end

    def test_error_includes_available_keys
      schema = {
        name: { type: String },
        age: { type: Integer }
      }
      receiver = build_receiver( schema: schema )

      error = assert_raises NoMethodError do
        receiver.unknown
      end

      assert_includes error.message, 'name'
      assert_includes error.message, 'age'
    end
  end

  # tests for inspect and to_s
  class InspectionTest < Minitest::Test
    include TestHelper

    def test_inspect_returns_string
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )
      receiver.name 'Alice'

      result = receiver.inspect
      assert_instance_of String, result
    end

    def test_to_s_returns_string
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )
      receiver.name 'Alice'

      result = receiver.to_s
      assert_instance_of String, result
    end
  end

  # tests for nil? method
  class NilTest < Minitest::Test
    include TestHelper

    def test_receiver_is_not_nil
      schema = { name: { type: String } }
      receiver = build_receiver( schema: schema )

      refute receiver.nil?
    end
  end

  # tests for as option in receiver
  class AsOptionTest < Minitest::Test
    include TestHelper

    def test_as_option_maps_to_different_key
      schema = {
        api_key: { type: String, as: :authorization }
      }
      receiver = build_receiver( schema: schema )
      receiver.api_key 'secret'

      result = receiver.to_h
      assert_equal 'secret', result[ :authorization ]
      assert_nil result[ :api_key ]
    end

    def test_as_option_with_initial_values
      schema = {
        api_key: { type: String, as: :authorization }
      }
      receiver = build_receiver( { api_key: 'from-init' }, schema: schema )

      result = receiver.to_h
      assert_equal 'from-init', result[ :authorization ]
    end
  end

end
