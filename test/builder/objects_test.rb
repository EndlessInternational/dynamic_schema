require_relative '../test_helper'

module Builder

  class ObjectsTest < Minitest::Test
    include TestHelper

    def test_defines_simple_object
      builder = build_schema do
        user do
          name String
          age Integer
        end
      end

      result = builder.build do
        user do
          name 'Alice'
          age 30
        end
      end

      assert_equal 'Alice', result[ :user ][ :name ]
      assert_equal 30, result[ :user ][ :age ]
    end

    def test_object_not_present_when_not_called
      builder = build_schema do
        optional_settings do
          theme String
        end
      end

      result = builder.build {}
      assert_nil result[ :optional_settings ]
    end

    def test_nested_objects
      builder = build_schema do
        level1 do
          value1 String
          level2 do
            value2 String
            level3 do
              value3 String
            end
          end
        end
      end

      result = builder.build do
        level1 do
          value1 'one'
          level2 do
            value2 'two'
            level3 do
              value3 'three'
            end
          end
        end
      end

      assert_equal 'one', result[ :level1 ][ :value1 ]
      assert_equal 'two', result[ :level1 ][ :level2 ][ :value2 ]
      assert_equal 'three', result[ :level1 ][ :level2 ][ :level3 ][ :value3 ]
    end

    def test_object_with_hash_input
      builder = build_schema do
        settings do
          theme String
          timeout Integer
        end
      end

      result = builder.build do
        settings( { theme: 'dark', timeout: 30 } )
      end

      assert_equal 'dark', result[ :settings ][ :theme ]
      assert_equal 30, result[ :settings ][ :timeout ]
    end

    def test_object_with_mixed_input
      builder = build_schema do
        settings do
          theme String
          timeout Integer
          debug [ TrueClass, FalseClass ]
        end
      end

      result = builder.build do
        settings( { theme: 'dark' } ) do
          timeout 30
          debug true
        end
      end

      assert_equal 'dark', result[ :settings ][ :theme ]
      assert_equal 30, result[ :settings ][ :timeout ]
      assert_equal true, result[ :settings ][ :debug ]
    end
  end

end
