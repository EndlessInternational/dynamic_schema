require_relative '../test_helper'

module StructTests

  # tests for struct inheritance
  class InheritanceTest < Minitest::Test

    def test_inherits_from_parent_schema
      parent_schema = proc do
        parent_value String
      end

      child_class = DynamicSchema::Struct.define( inherit: parent_schema ) do
        child_value Integer
      end

      instance = child_class.build( parent_value: 'from parent', child_value: 42 )

      assert_equal 'from parent', instance.parent_value
      assert_equal 42, instance.child_value
    end

    def test_inherits_from_builder_schema
      parent_builder = DynamicSchema.define do
        name String
        age Integer
      end

      child_class = DynamicSchema::Struct.define( inherit: parent_builder.schema ) do
        email String
      end

      instance = child_class.build( name: 'Alice', age: 30, email: 'alice@example.com' )

      assert_equal 'Alice', instance.name
      assert_equal 30, instance.age
      assert_equal 'alice@example.com', instance.email
    end

    def test_struct_from_existing_compiled_schema
      parent_class = DynamicSchema::Struct.define do
        base_field String
        count Integer
      end

      # create a new struct from an existing struct's compiled schema
      child_class = DynamicSchema::Struct.new( parent_class.compiled_schema )

      instance = child_class.build( base_field: 'test', count: 42 )

      assert_equal 'test', instance.base_field
      assert_equal 42, instance.count
    end

    def test_inherited_defaults_apply
      parent_schema = proc do
        version String, default: '1.0'
      end

      child_class = DynamicSchema::Struct.define( inherit: parent_schema ) do
        name String
      end

      instance = child_class.build( name: 'test' )

      assert_equal '1.0', instance.version
      assert_equal 'test', instance.name
    end

    def test_inherited_validation_applies
      parent_schema = proc do
        count Integer, required: true
      end

      child_class = DynamicSchema::Struct.define( inherit: parent_schema ) do
        label String
      end

      assert_raises DynamicSchema::RequiredOptionError do
        child_class.build!( label: 'test' )
      end
    end

    def test_to_h_includes_inherited_fields
      parent_schema = proc do
        parent_field String
      end

      child_class = DynamicSchema::Struct.define( inherit: parent_schema ) do
        child_field Integer
      end

      instance = child_class.build( parent_field: 'parent', child_field: 42 )
      hash = instance.to_h

      assert_equal 'parent', hash[ :parent_field ]
      assert_equal 42, hash[ :child_field ]
    end

  end

  # tests for using one struct as a field type in another
  class ReferencedStructTest < Minitest::Test

    def test_struct_as_single_field_type
      address_class = DynamicSchema::Struct.define do
        street String
        city String
      end

      person_class = DynamicSchema::Struct.define do
        name String
        address address_class
      end

      person = person_class.build(
        name: 'Alice',
        address: { street: '123 Main St', city: 'Boston' }
      )

      assert_equal 'Alice', person.name
      assert_equal '123 Main St', person.address.street
      assert_equal 'Boston', person.address.city
    end

    def test_struct_as_array_field_type
      item_class = DynamicSchema::Struct.define do
        name String
        quantity Integer
      end

      order_class = DynamicSchema::Struct.define do
        order_number String
        items item_class, array: true
      end

      order = order_class.build(
        order_number: 'ORD-001',
        items: [
          { name: 'Widget', quantity: 5 },
          { name: 'Gadget', quantity: 3 }
        ]
      )

      assert_equal 'ORD-001', order.order_number
      assert_equal 2, order.items.length
      assert_equal 'Widget', order.items[ 0 ].name
      assert_equal 5, order.items[ 0 ].quantity
      assert_equal 'Gadget', order.items[ 1 ].name
      assert_equal 3, order.items[ 1 ].quantity
    end

    def test_referenced_struct_to_h
      inner_class = DynamicSchema::Struct.define do
        value Integer
      end

      outer_class = DynamicSchema::Struct.define do
        inner inner_class
      end

      instance = outer_class.build( inner: { value: 42 } )
      hash = instance.to_h

      assert_instance_of Hash, hash[ :inner ]
      assert_equal 42, hash[ :inner ][ :value ]
    end

    def test_referenced_struct_array_to_h
      item_class = DynamicSchema::Struct.define do
        name String
      end

      container_class = DynamicSchema::Struct.define do
        items item_class, array: true
      end

      instance = container_class.build( items: [ { name: 'one' }, { name: 'two' } ] )
      hash = instance.to_h

      assert_instance_of Array, hash[ :items ]
      assert_equal 'one', hash[ :items ][ 0 ][ :name ]
      assert_equal 'two', hash[ :items ][ 1 ][ :name ]
    end

    def test_referenced_struct_validates
      inner_class = DynamicSchema::Struct.define do
        count Integer
      end

      outer_class = DynamicSchema::Struct.define do
        inner inner_class
      end

      instance = outer_class.build( inner: { count: 'not-an-integer' } )

      refute instance.valid?
    end

    def test_deeply_nested_referenced_structs
      level3_class = DynamicSchema::Struct.define do
        value String
      end

      level2_class = DynamicSchema::Struct.define do
        level3 level3_class
      end

      level1_class = DynamicSchema::Struct.define do
        level2 level2_class
      end

      instance = level1_class.build(
        level2: { level3: { value: 'deep' } }
      )

      assert_equal 'deep', instance.level2.level3.value
    end

  end

end
