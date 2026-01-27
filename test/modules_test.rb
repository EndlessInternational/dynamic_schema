require_relative 'test_helper'

# tests for DynamicSchema.define
class ModuleDefineTest < Minitest::Test

  def test_define_returns_builder
    builder = DynamicSchema.define {}
    assert_instance_of DynamicSchema::Builder, builder
  end

  def test_define_with_schema
    builder = DynamicSchema.define do
      name String
    end

    result = builder.build { name 'test' }
    assert_equal 'test', result[ :name ]
  end

end

# tests for DynamicSchema::Definable module
module Definable

  class BasicDefinableTest < Minitest::Test

    def setup
      @base_class = Class.new do
        include DynamicSchema::Definable
        schema do
          value_a
        end
      end
    end

    def test_schema_method_returns_proc
      assert_instance_of Proc, @base_class.schema
    end

    def test_schema_defines_buildable_schema
      result = DynamicSchema.define( &@base_class.schema ).build do
        value_a 'A'
      end

      assert_equal 'A', result[ :value_a ]
    end

    def test_builder_method_returns_builder
      assert_instance_of DynamicSchema::Builder, @base_class.builder
    end

    def test_builder_can_build_schema
      result = @base_class.builder.build { value_a 'A' }
      assert_equal 'A', result[ :value_a ]
    end

    def test_builder_rejects_undefined_values
      assert_raises NoMethodError do
        @base_class.builder.build { undefined_value 'X' }
      end
    end

  end

  class InheritanceTest < Minitest::Test

    def setup
      @class_a = Class.new do
        include DynamicSchema::Definable
        schema do
          value_a
        end
      end

      @class_b = Class.new( @class_a ) do
        schema do
          value_b
        end
      end

      @class_c = Class.new( @class_b ) do
        schema do
          value_c
        end
      end
    end

    def test_child_inherits_parent_schema
      result = @class_b.builder.build do
        value_a 'A'
        value_b 'B'
      end

      assert_equal 'A', result[ :value_a ]
      assert_equal 'B', result[ :value_b ]
    end

    def test_grandchild_inherits_all_ancestors
      result = @class_c.builder.build do
        value_a 'A'
        value_b 'B'
        value_c 'C'
      end

      assert_equal 'A', result[ :value_a ]
      assert_equal 'B', result[ :value_b ]
      assert_equal 'C', result[ :value_c ]
    end

    def test_parent_does_not_see_child_values
      assert_raises NoMethodError do
        @class_a.builder.build { value_b 'B' }
      end
    end

    def test_child_cannot_use_sibling_values
      class_d = Class.new( @class_a ) do
        schema do
          value_d
        end
      end

      assert_raises NoMethodError do
        class_d.builder.build { value_b 'B' }
      end
    end

  end

  class OverrideTest < Minitest::Test

    def setup
      @class_a = Class.new do
        include DynamicSchema::Definable
        schema do
          value_a
        end
      end

      # class_d redefines value_a and adds value_d
      @class_d = Class.new( @class_a ) do
        schema do
          value_a
          value_d
        end
      end
    end

    def test_child_can_override_parent_definition
      result = @class_d.builder.build do
        value_a 'A'
        value_d 'D'
      end

      assert_equal 'A', result[ :value_a ]
      assert_equal 'D', result[ :value_d ]
    end

    def test_override_does_not_affect_parent
      # parent still only has value_a
      result = @class_a.builder.build { value_a 'original' }
      assert_equal 'original', result[ :value_a ]

      assert_raises NoMethodError do
        @class_a.builder.build { value_d 'D' }
      end
    end

  end

end

# tests for DynamicSchema::Buildable module
module Buildable

  class BasicBuildableTest < Minitest::Test

    def setup
      @setting_class = Class.new do
        include DynamicSchema::Definable
        include DynamicSchema::Buildable

        schema do
          name String
          value Integer
        end

        attr_reader :attributes

        def initialize( attributes = {} )
          @attributes = attributes
        end
      end
    end

    def test_build_creates_instance_with_hash
      instance = @setting_class.build( { name: 'test', value: 42 } )

      assert_instance_of @setting_class, instance
      assert_equal 'test', instance.attributes[ :name ]
      assert_equal 42, instance.attributes[ :value ]
    end

    def test_build_creates_instance_with_block
      instance = @setting_class.build do
        name 'from-block'
        value 100
      end

      assert_equal 'from-block', instance.attributes[ :name ]
      assert_equal 100, instance.attributes[ :value ]
    end

    def test_build_combines_hash_and_block
      instance = @setting_class.build( { name: 'from-hash' } ) do
        value 200
      end

      assert_equal 'from-hash', instance.attributes[ :name ]
      assert_equal 200, instance.attributes[ :value ]
    end

    def test_build_bang_validates
      assert_raises DynamicSchema::IncompatibleTypeError do
        @setting_class.build!( { value: 'not-an-integer' } )
      end
    end

    def test_build_does_not_validate
      # should not raise - build without ! does not validate
      instance = @setting_class.build( { value: 'not-an-integer' } )
      # the value is kept as-is since coercion failed
      assert_equal 'not-an-integer', instance.attributes[ :value ]
    end

  end

  class InheritedBuildableTest < Minitest::Test

    def setup
      @base_class = Class.new do
        include DynamicSchema::Definable
        include DynamicSchema::Buildable

        schema do
          name String
        end

        attr_reader :attributes

        def initialize( attributes = {} )
          @attributes = attributes
        end
      end

      @child_class = Class.new( @base_class ) do
        schema do
          database do
            host String
            port Integer
          end
        end
      end
    end

    def test_child_can_build_with_inherited_and_new_values
      instance = @child_class.build! do
        name 'settings'
        database do
          host 'localhost'
          port 5432
        end
      end

      assert_equal 'settings', instance.attributes[ :name ]
      assert_equal 'localhost', instance.attributes[ :database ][ :host ]
      assert_equal 5432, instance.attributes[ :database ][ :port ]
    end

  end

end
