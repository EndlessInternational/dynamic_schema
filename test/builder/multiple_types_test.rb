require_relative '../test_helper'

module Builder
  module MultipleTypes

    class BasicTest < Minitest::Test
      include TestHelper

      def test_with_object_and_boolean_using_block
        builder = build_schema do
          some_parameter [ Object, TrueClass, FalseClass ] do
            nested_parameter String
          end
        end

        result = builder.build do
          some_parameter do
            nested_parameter 'hello'
          end
        end

        assert_equal 'hello', result[ :some_parameter ][ :nested_parameter ]
      end

      def test_with_object_and_boolean_using_true
        builder = build_schema do
          some_parameter [ Object, TrueClass, FalseClass ] do
            nested_parameter String
          end
        end

        result = builder.build do
          some_parameter true
        end

        assert_equal true, result[ :some_parameter ]
      end

      def test_with_object_and_boolean_using_false
        builder = build_schema do
          some_parameter [ Object, TrueClass, FalseClass ] do
            nested_parameter String
          end
        end

        result = builder.build do
          some_parameter false
        end

        assert_equal false, result[ :some_parameter ]
      end

      def test_with_hash_input_treated_as_object
        builder = build_schema do
          some_parameter [ Object, TrueClass, FalseClass ] do
            nested_parameter String
          end
        end

        result = builder.build do
          some_parameter( { nested_parameter: 'from hash' } )
        end

        assert_equal 'from hash', result[ :some_parameter ][ :nested_parameter ]
      end

      def test_preserves_nested_schema
        builder = build_schema do
          config [ Object, TrueClass, FalseClass ] do
            setting1 String
            setting2 Integer
          end
        end

        result = builder.build do
          config do
            setting1 'value1'
            setting2 123
          end
        end

        assert_equal 'value1', result[ :config ][ :setting1 ]
        assert_equal 123, result[ :config ][ :setting2 ]
      end

      def test_with_custom_class
        custom_class = Class.new do
          attr_reader :value
          def initialize( value )
            @value = value
          end
        end

        builder = build_schema do
          data [ Object, custom_class ] do
            name String
          end
        end

        instance = custom_class.new( 'test' )
        result = builder.build do
          data instance
        end

        assert_equal instance, result[ :data ]
      end

      def test_with_custom_class_no_object
        custom_class = Class.new do
          attr_reader :value
          def initialize( value = nil )
            @value = value
          end
        end

        builder = build_schema do
          data [ custom_class, TrueClass, FalseClass ] do
            name String
          end
        end

        result = builder.build do
          data( { name: 'from hash' } )
        end
        assert_equal 'from hash', result[ :data ][ :name ]

        result = builder.build do
          data true
        end
        assert_equal true, result[ :data ]

        instance = custom_class.new( 'test' )
        result = builder.build do
          data instance
        end
        assert_equal instance, result[ :data ]
      end

    end

    class NestingTest < Minitest::Test
      include TestHelper

      def test_nested_multiple_types_both_as_objects
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          outer do
            inner do
              value 'deep'
            end
          end
        end

        assert_equal 'deep', result[ :outer ][ :inner ][ :value ]
      end

      def test_nested_multiple_types_outer_boolean_skips_inner
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          outer true
        end

        assert_equal true, result[ :outer ]
      end

      def test_nested_multiple_types_inner_as_boolean
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          outer do
            inner false
          end
        end

        assert_equal false, result[ :outer ][ :inner ]
      end

      def test_three_levels_of_nesting
        builder = build_schema do
          level1 [ Object, TrueClass, FalseClass ] do
            level2 [ Object, TrueClass, FalseClass ] do
              level3 [ Object, TrueClass, FalseClass ] do
                value String
              end
            end
          end
        end

        result = builder.build do
          level1 do
            level2 do
              level3 do
                value 'deepest'
              end
            end
          end
        end

        assert_equal 'deepest', result[ :level1 ][ :level2 ][ :level3 ][ :value ]
      end

      def test_three_levels_with_mixed_types
        builder = build_schema do
          level1 [ Object, TrueClass, FalseClass ] do
            level2 [ Object, TrueClass, FalseClass ] do
              level3 [ Object, TrueClass, FalseClass ] do
                value String
              end
            end
          end
        end

        result = builder.build do
          level1 do
            level2 true
          end
        end

        assert_equal true, result[ :level1 ][ :level2 ]
      end

      def test_nested_with_sibling_multiple_types
        builder = build_schema do
          config [ Object, TrueClass, FalseClass ] do
            feature1 [ Object, TrueClass, FalseClass ] do
              enabled [ TrueClass, FalseClass ]
            end
            feature2 [ Object, TrueClass, FalseClass ] do
              enabled [ TrueClass, FalseClass ]
            end
          end
        end

        result = builder.build do
          config do
            feature1 do
              enabled true
            end
            feature2 false
          end
        end

        assert_equal true, result[ :config ][ :feature1 ][ :enabled ]
        assert_equal false, result[ :config ][ :feature2 ]
      end

      def test_nested_with_hash_input
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          outer( { inner: { value: 'from hash' } } )
        end

        assert_equal 'from hash', result[ :outer ][ :inner ][ :value ]
      end

      def test_nested_with_mixed_hash_and_boolean
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        result = builder.build do
          outer( { inner: true } )
        end

        assert_equal true, result[ :outer ][ :inner ]
      end

    end

    class ValidationTest < Minitest::Test
      include TestHelper

      def test_validates_nested_object_types
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            count Integer
          end
        end

        result = builder.build do
          data do
            count 42
          end
        end

        assert builder.valid?( result )
      end

      def test_validates_boolean_value
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            count Integer
          end
        end

        result = builder.build do
          data true
        end

        assert builder.valid?( result )
      end

      def test_invalid_scalar_type
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            count Integer
          end
        end

        result = builder.build do
          data 'invalid string'
        end

        refute builder.valid?( result )
      end

      def test_validates_deeply_nested_types
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        result = builder.build do
          outer do
            inner do
              value 123
            end
          end
        end

        assert builder.valid?( result )
      end

      def test_validates_nested_with_inner_boolean
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        result = builder.build do
          outer do
            inner true
          end
        end

        assert builder.valid?( result )
      end

      def test_invalid_nested_inner_type
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        result = builder.build do
          outer do
            inner 'invalid'
          end
        end

        refute builder.valid?( result )
      end

    end

  end
end
