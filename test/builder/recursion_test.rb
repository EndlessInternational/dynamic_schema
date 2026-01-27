require_relative '../test_helper'

module Builder

  # tests for recursive schema definitions
  class RecursionTest < Minitest::Test
    include TestHelper

    def test_constructs_recursive_schema_without_stack_overflow
      recursive_schema = nil
      recursive_schema = proc do
        value
        nested &recursive_schema
      end

      builder = DynamicSchema::Builder.new.define( &recursive_schema )
      assert_instance_of DynamicSchema::Builder, builder
    end

    def test_recursive_schema_allows_multiple_levels
      recursive_schema = nil
      recursive_schema = proc do
        value
        nested &recursive_schema
      end

      builder = DynamicSchema::Builder.new.define( &recursive_schema )

      result = builder.build! do
        value :one
        nested do
          value :two
          nested do
            value :three
            nested do
              value :four
            end
          end
        end
      end

      assert_equal :one, result[ :value ]
      assert_equal :two, result[ :nested ][ :value ]
      assert_equal :three, result[ :nested ][ :nested ][ :value ]
      assert_equal :four, result[ :nested ][ :nested ][ :nested ][ :value ]
    end

    def test_recursive_schema_with_typed_values
      recursive_schema = nil
      recursive_schema = proc do
        name String
        children &recursive_schema
      end

      builder = DynamicSchema::Builder.new.define( &recursive_schema )

      result = builder.build! do
        name 'parent'
        children do
          name 'child'
          children do
            name 'grandchild'
          end
        end
      end

      assert_equal 'parent', result[ :name ]
      assert_equal 'child', result[ :children ][ :name ]
      assert_equal 'grandchild', result[ :children ][ :children ][ :name ]
    end

  end

end
