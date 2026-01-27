require_relative '../test_helper'

module Builder

  class InheritanceTest < Minitest::Test
    include TestHelper

    def test_inherits_from_parent_schema
      parent_schema = proc do
        parent_value String
      end

      builder = DynamicSchema::Builder.new.define( inherit: parent_schema ) do
        child_value Integer
      end

      result = builder.build do
        parent_value 'from parent'
        child_value 42
      end

      assert_equal 'from parent', result[ :parent_value ]
      assert_equal 42, result[ :child_value ]
    end

    def test_parent_schema_only
      parent_schema = proc do
        parent_value String
      end

      builder = DynamicSchema::Builder.new.define( inherit: parent_schema )

      result = builder.build do
        parent_value 'from parent'
      end

      assert_equal 'from parent', result[ :parent_value ]
    end

    def test_child_cannot_use_parent_only_fields_without_inherit
      parent_schema = proc do
        parent_value String
      end

      DynamicSchema::Builder.new.define( inherit: parent_schema ) do
        child_value Integer
      end

      builder_without_inherit = DynamicSchema::Builder.new.define do
        child_value Integer
      end

      assert_raises NoMethodError do
        builder_without_inherit.build { parent_value 'test' }
      end
    end

    def test_inherits_from_definable_class
      parent_class = Class.new do
        include DynamicSchema::Definable
        schema do
          inherited_value String
        end
      end

      builder = DynamicSchema::Builder.new.define( inherit: parent_class.schema ) do
        new_value Integer
      end

      result = builder.build do
        inherited_value 'from class'
        new_value 100
      end

      assert_equal 'from class', result[ :inherited_value ]
      assert_equal 100, result[ :new_value ]
    end
  end

  class BuildFromBytesTest < Minitest::Test
    include TestHelper

    def test_builds_from_ruby_code_string
      builder = build_schema do
        name String
        age Integer
      end

      code = <<~RUBY
        name 'Alice'
        age 30
      RUBY

      result = builder.build_from_bytes( code )

      assert_equal 'Alice', result[ :name ]
      assert_equal 30, result[ :age ]
    end

    def test_builds_from_bytes_with_initial_values
      builder = build_schema do
        name String
        age Integer
      end

      code = "age 30"

      result = builder.build_from_bytes( code, values: { name: 'Bob' } )

      assert_equal 'Bob', result[ :name ]
      assert_equal 30, result[ :age ]
    end

    def test_build_from_bytes_bang_validates
      builder = build_schema do
        value Integer, required: true
      end

      code = "# empty"

      assert_raises DynamicSchema::RequiredOptionError do
        builder.build_from_bytes!( code )
      end
    end
  end

  class SchemaMethodTest < Minitest::Test
    include TestHelper

    def test_schema_returns_proc
      builder = build_schema do
        value String
      end

      schema = builder.schema
      assert_instance_of Proc, schema
    end

    def test_schema_can_be_reused
      builder = build_schema do
        value String
      end

      new_builder = DynamicSchema::Builder.new.define( inherit: builder.schema )

      result = new_builder.build { value 'test' }
      assert_equal 'test', result[ :value ]
    end
  end

end
