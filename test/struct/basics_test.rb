require_relative '../test_helper'

module StructTests

  # tests for struct initialization and building
  class InitializationTest < Minitest::Test

    def test_define_creates_struct_class
      struct_class = DynamicSchema::Struct.define do
        name String
      end

      assert struct_class < DynamicSchema::Struct
    end

    def test_build_creates_instance
      struct_class = DynamicSchema::Struct.define do
        name String
      end

      instance = struct_class.build( name: 'Alice' )
      assert_equal 'Alice', instance.name
    end

    def test_new_accepts_values
      struct_class = DynamicSchema::Struct.define do
        name String
      end

      instance = struct_class.new( name: 'Bob' )
      assert_equal 'Bob', instance.name
    end

    def test_build_with_block
      struct_class = DynamicSchema::Struct.define do
        full_name String
      end

      instance = struct_class.build do | i |
        i.full_name = 'Carol Johnson'
      end

      assert_equal 'Carol Johnson', instance.full_name
    end

    def test_accessors_read_and_write
      struct_class = DynamicSchema::Struct.define do
        name String
        quantity Integer
        in_stock [ TrueClass, FalseClass ], default: false
      end

      instance = struct_class.build( name: 'Desk', quantity: 1, in_stock: true )
      assert_equal 'Desk', instance.name
      assert_equal 1, instance.quantity
      assert_equal true, instance.in_stock

      instance.name = 'Chair'
      instance.quantity = 2
      assert_equal 'Chair', instance.name
      assert_equal 2, instance.quantity
    end

    def test_coerces_values_on_build
      struct_class = DynamicSchema::Struct.define do
        age Integer
      end

      instance = struct_class.build( age: '42' )
      assert_equal 42, instance.age
    end

    def test_defaults_are_applied
      struct_class = DynamicSchema::Struct.define do
        version String, default: '1.0'
      end

      instance = struct_class.build
      assert_equal '1.0', instance.version
    end
  end

  # tests for creating struct from different sources
  class SourcesTest < Minitest::Test

    def test_new_with_proc
      person_class = DynamicSchema::Struct.new( proc { first_name String } )
      person = person_class.build( first_name: 'Alice' )

      assert_equal 'Alice', person.first_name

      person.first_name = 'Bob'
      assert_equal 'Bob', person.first_name
    end

    def test_new_with_builder
      builder = DynamicSchema.define do
        category String
      end

      category_class = DynamicSchema::Struct.new( builder )
      instance = category_class.build( category: 'Furniture' )

      assert_equal 'Furniture', instance.category
    end

    def test_new_with_compiled_hash
      compiled = { title: { type: String } }
      book_class = DynamicSchema::Struct.new( compiled )

      book = book_class.build( title: 'Dune' )
      assert_equal 'Dune', book.title
    end
  end

  # tests for as option aliasing
  class AsOptionTest < Minitest::Test

    def test_as_option_aliases_accessor
      document_class = DynamicSchema::Struct.define do
        title String, as: :original_title
      end

      doc = document_class.build( original_title: 'Quarterly Report' )
      assert_equal 'Quarterly Report', doc.title
      refute doc.respond_to?( :original_title )

      doc.title = 'Annual Report'
      assert_equal 'Annual Report', doc.title
      assert_includes doc.to_h, :original_title
      assert_equal 'Annual Report', doc.to_h[ :original_title ]
    end
  end

  # tests for array fields
  class ArrayFieldsTest < Minitest::Test

    def test_scalar_array_field
      inventory_class = DynamicSchema::Struct.define do
        quantities Integer, array: true
      end

      inventory = inventory_class.build( quantities: [ 1, 2, 3 ] )
      assert_equal [ 1, 2, 3 ], inventory.quantities

      inventory.quantities = [ 4, 5 ]
      assert_equal [ 4, 5 ], inventory.quantities
    end

    def test_coerces_array_elements
      struct_class = DynamicSchema::Struct.define do
        numbers Integer, array: true
      end

      instance = struct_class.build( numbers: [ '1', '2', '3' ] )
      assert_equal [ 1, 2, 3 ], instance.numbers
    end
  end

end
