require_relative '../test_helper'

module StructTests

  # tests for struct to_h method
  class ToHashTest < Minitest::Test

    def test_converts_simple_struct_to_hash
      klass = DynamicSchema::Struct.define do
        name String
        age Integer
      end

      instance = klass.build
      instance.name = 'Alice'
      instance.age = 30

      expected = { name: 'Alice', age: 30 }
      assert_equal expected, instance.to_h
    end

    def test_converts_nested_object_to_hash
      klass = DynamicSchema::Struct.define do
        api_key String
        options do
          model String
        end
      end

      instance = klass.build
      instance.api_key = 'test-key'
      instance.options.model = 'test-model'

      expected = {
        api_key: 'test-key',
        options: { model: 'test-model' }
      }
      assert_equal expected, instance.to_h
    end

    def test_handles_empty_struct
      empty_class = DynamicSchema::Struct.define {}

      instance = empty_class.build
      assert_equal( {}, instance.to_h )
    end

    def test_handles_nested_arrays_of_objects
      klass = DynamicSchema::Struct.define do
        messages array: true do
          role String
          content String
        end
      end

      instance = klass.build
      instance.messages = [
        { role: 'user', content: 'Hello!' },
        { role: 'assistant', content: 'Hi there!' }
      ]

      expected = {
        messages: [
          { role: 'user', content: 'Hello!' },
          { role: 'assistant', content: 'Hi there!' }
        ]
      }
      assert_equal expected, instance.to_h
    end

    def test_omits_empty_nested_objects
      klass = DynamicSchema::Struct.define do
        meta do
          tag String
        end
      end

      instance = klass.build
      assert_equal( {}, instance.meta.to_h )
      assert_equal( {}, instance.to_h )
    end

    def test_omits_empty_arrays
      klass = DynamicSchema::Struct.define do
        items array: true do
          value Integer
        end
      end

      instance = klass.build
      assert_equal( {}, instance.to_h )

      instance.items = []
      assert_equal( {}, instance.to_h )
    end

    def test_applies_as_alias_in_output
      klass = DynamicSchema::Struct.define do
        title String, as: :original_title
        people array: true, as: :person do
          full_name String
        end
      end

      instance = klass.build
      instance.title = 'Quarterly Report'
      instance.people = [ { full_name: 'Sam Lee' } ]

      expected = {
        original_title: 'Quarterly Report',
        person: [ { full_name: 'Sam Lee' } ]
      }
      assert_equal expected, instance.to_h
    end

    def test_preserves_custom_class_values
      customer_class = Class.new do
        attr_accessor :name
      end

      klass = DynamicSchema::Struct.define do
        customer customer_class
      end

      instance = klass.build
      customer = customer_class.new
      customer.name = 'Kristoph'
      instance.customer = customer

      result = instance.to_h
      assert_instance_of customer_class, result[ :customer ]
      assert_equal 'Kristoph', result[ :customer ].name
    end

    def test_preserves_array_of_custom_class_values
      customer_class = Class.new do
        attr_accessor :name
      end

      klass = DynamicSchema::Struct.define do
        customers customer_class, array: true
      end

      instance = klass.build
      c1 = customer_class.new
      c1.name = 'A'
      c2 = customer_class.new
      c2.name = 'B'
      instance.customers = [ c1, c2 ]

      result = instance.to_h
      assert_instance_of Array, result[ :customers ]
      assert_equal [ 'A', 'B' ], result[ :customers ].map( &:name )
    end

  end

end
