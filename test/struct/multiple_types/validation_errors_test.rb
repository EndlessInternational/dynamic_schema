require_relative '../../test_helper'

module StructTests
  module MultipleTypes

    class ValidationErrorsTest < Minitest::Test

      def test_error_path_for_scalar_type_mismatch
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: 'invalid string' )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
        assert_equal 'data', errors[ 0 ].keypath
      end

      def test_error_path_for_nested_object_type_mismatch
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        instance = struct_class.build( data: { value: 'not an integer' } )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
        assert_equal 'data/value', errors[ 0 ].keypath
      end

      def test_error_path_for_deeply_nested_type_mismatch
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        instance = struct_class.build(
          outer: { inner: { value: 'not an integer' } }
        )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_equal 'outer/inner/value', errors[ 0 ].keypath
      end

      def test_error_path_for_invalid_nested_scalar
        struct_class = DynamicSchema::Struct.define do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, Integer, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        instance = struct_class.build(
          outer: { inner: 'invalid string' }
        )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_equal 'outer/inner', errors[ 0 ].keypath
      end

      def test_error_path_for_array_element
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build(
          items: [
            { value: 123 },
            'invalid string',
            { value: 456 }
          ]
        )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_equal 'items', errors[ 0 ].keypath
      end

      def test_error_path_for_nested_object_in_array
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        instance = struct_class.build(
          items: [
            { value: 123 },
            { value: 'not an integer' }
          ]
        )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_equal 'items/value', errors[ 0 ].keypath
      end

      def test_multiple_errors_at_different_paths
        struct_class = DynamicSchema::Struct.define do
          first [ Object, TrueClass, FalseClass ] do
            value Integer
          end
          second [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        instance = struct_class.build(
          first: 'invalid',
          second: { value: 'also invalid' }
        )
        errors = instance.validate

        assert_equal 2, errors.length
        keypaths = errors.map( &:keypath ).sort
        assert_equal [ 'first', 'second/value' ], keypaths
      end

      def test_error_for_required_nested_field
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value Integer, required: true
          end
        end

        instance = struct_class.build( data: {} )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]
        assert_equal 'data/value', errors[ 0 ].keypath
      end

      def test_error_for_in_option_in_nested
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            status Symbol, in: [ :active, :inactive ]
          end
        end

        instance = struct_class.build( data: { status: :unknown } )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]
        assert_equal 'data/status', errors[ 0 ].keypath
      end

      def test_error_types_array_shown_in_message
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: 123 )
        errors = instance.validate

        assert_equal 1, errors.length
        assert_includes errors[ 0 ].message, 'TrueClass'
        assert_includes errors[ 0 ].message, 'FalseClass'
      end

      def test_valid_returns_false_for_invalid_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: 'invalid' )

        refute instance.valid?
      end

      def test_valid_returns_false_for_invalid_nested
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        instance = struct_class.build( data: { value: 'not an integer' } )

        refute instance.valid?
      end

      def test_valid_returns_true_for_valid_scalar
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = struct_class.build( data: true )

        assert instance.valid?
      end

      def test_valid_returns_true_for_valid_nested
        struct_class = DynamicSchema::Struct.define do
          data [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        instance = struct_class.build( data: { value: 42 } )

        assert instance.valid?
      end

    end

  end
end
