require_relative '../test_helper'

module StructTests
  module MultipleTypes

    class BasicTest < Minitest::Test

      def test_with_hash_value_becomes_nested_struct
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
            value Integer
          end
        end

        instance = struct_class.build( data: { name: 'test', value: 42 } )

        assert_respond_to instance.data, :name
        assert_respond_to instance.data, :value
        assert_equal 'test', instance.data.name
        assert_equal 42, instance.data.value
      end

      def test_with_true_value
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: true )

        assert_equal true, instance.data
      end

      def test_with_false_value
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: false )

        assert_equal false, instance.data
      end

      def test_nil_value
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: nil )

        assert_nil instance.data
      end

      def test_setter_clears_cache
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: { name: 'original' } )
        assert_equal 'original', instance.data.name

        instance.data = true
        assert_equal true, instance.data
      end

      def test_with_custom_struct_type
        inner_struct = DynamicSchema::Struct.define do
          name String
          value Integer
        end

        struct_class = DynamicSchema::Struct.define do
          data [ Object, inner_struct, TrueClass, FalseClass ] do
            label String
          end
        end

        instance = struct_class.build( data: { label: 'test' } )
        assert_equal 'test', instance.data.label
      end

      def test_without_object_type
        struct_class = DynamicSchema::Struct.define do
          data [ String, TrueClass, FalseClass ] do
            name String
            value Integer
          end
        end

        instance = struct_class.build( data: { name: 'test', value: 42 } )
        assert_respond_to instance.data, :name
        assert_equal 'test', instance.data.name
        assert_equal 42, instance.data.value

        instance = struct_class.build( data: 'hello' )
        assert_equal 'hello', instance.data

        instance = struct_class.build( data: true )
        assert_equal true, instance.data
      end

    end

    class ToHashTest < Minitest::Test

      def test_to_h_with_hash_value
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ] do
            enabled [ TrueClass, FalseClass ]
            timeout Integer
          end
        end

        instance = struct_class.build( config: { enabled: true, timeout: 30 } )
        result = instance.to_h

        assert_equal( { enabled: true, timeout: 30 }, result[ :config ] )
      end

      def test_to_h_with_boolean_value
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ] do
            timeout Integer
          end
        end

        instance = struct_class.build( config: true )
        result = instance.to_h

        assert_equal true, result[ :config ]
      end

    end

    class NestingTest < Minitest::Test

      def test_nested_multiple_types_both_as_objects
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( outer: { inner: { value: 'deep' } } )

        assert_equal 'deep', instance.outer.inner.value
      end

      def test_nested_multiple_types_outer_boolean
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( outer: true )

        assert_equal true, instance.outer
      end

      def test_nested_multiple_types_inner_as_boolean
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( outer: { inner: false } )

        assert_equal false, instance.outer.inner
      end

      def test_three_levels_of_nesting
        struct_class = DynamicSchema::Struct.define do
          level1 [ Object, TrueClass, FalseClass ] do
            level2 [ Object, TrueClass, FalseClass ] do
              level3 [ Object, TrueClass, FalseClass ] do
                value String
              end
            end
          end
        end

        instance = struct_class.build( level1: { level2: { level3: { value: 'deepest' } } } )

        assert_equal 'deepest', instance.level1.level2.level3.value
      end

      def test_three_levels_with_mixed_types
        struct_class = DynamicSchema::Struct.define do
          level1 [ Object, TrueClass, FalseClass ] do
            level2 [ Object, TrueClass, FalseClass ] do
              level3 [ Object, TrueClass, FalseClass ] do
                value String
              end
            end
          end
        end

        instance = struct_class.build( level1: { level2: true } )

        assert_equal true, instance.level1.level2
      end

      def test_nested_with_sibling_multiple_types
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ] do
            feature1 [ Object, TrueClass, FalseClass ] do
              enabled [ TrueClass, FalseClass ]
            end
            feature2 [ Object, TrueClass, FalseClass ] do
              enabled [ TrueClass, FalseClass ]
            end
          end
        end

        instance = struct_class.build( config: {
          feature1: { enabled: true },
          feature2: false
        } )

        assert_equal true, instance.config.feature1.enabled
        assert_equal false, instance.config.feature2
      end

      def test_to_h_with_nested_multiple_types
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( outer: { inner: { value: 'test' } } )
        result = instance.to_h

        assert_equal( { inner: { value: 'test' } }, result[ :outer ] )
      end

      def test_to_h_with_nested_inner_boolean
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build( outer: { inner: true } )
        result = instance.to_h

        assert_equal( { inner: true }, result[ :outer ] )
      end

    end

    class ValidationTest < Minitest::Test

      def test_validation_with_object
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: { name: 'test' } )

        assert instance.valid?
      end

      def test_validation_with_boolean
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: true )

        assert instance.valid?
      end

      def test_invalid_scalar_type
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            name String
          end
        end

        instance = struct_class.build( data: 'invalid string' )

        refute instance.valid?
      end

      def test_validates_deeply_nested_types
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( outer: { inner: { value: 123 } } )

        assert instance.valid?
      end

      def test_validates_nested_with_inner_boolean
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( outer: { inner: true } )

        assert instance.valid?
      end

      def test_invalid_nested_inner_type
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( outer: { inner: 'invalid' } )

        refute instance.valid?
      end

      def test_validate_returns_errors_for_invalid_nested
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( outer: { inner: 'invalid' } )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_kind_of DynamicSchema::IncompatibleTypeError, errors.first
      end

      def test_validate_bang_raises_for_invalid_nested
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build( outer: { inner: 'invalid' } )

        assert_raises DynamicSchema::IncompatibleTypeError do
          instance.validate!
        end
      end

    end

  end
end
