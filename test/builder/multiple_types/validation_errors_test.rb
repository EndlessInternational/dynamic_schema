require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class ValidationErrorsTest < Minitest::Test
      include TestHelper

      def test_error_path_for_scalar_type_mismatch
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        errors = builder.validate( { data: 'invalid string' } )

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
        assert_equal 'data', errors[ 0 ].keypath
      end

      def test_error_path_for_nested_object_type_mismatch
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        errors = builder.validate( { data: { value: 'not an integer' } } )

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
        assert_equal 'data/value', errors[ 0 ].keypath
      end

      def test_error_path_for_deeply_nested_type_mismatch
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, TrueClass, FalseClass ] do
              value Integer
            end
          end
        end

        errors = builder.validate( {
          outer: { inner: { value: 'not an integer' } }
        } )

        assert_equal 1, errors.length
        assert_equal 'outer/inner/value', errors[ 0 ].keypath
      end

      def test_error_path_for_invalid_nested_scalar
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ] do
            inner [ Object, Integer, TrueClass, FalseClass ] do
              value String
            end
          end
        end

        errors = builder.validate( {
          outer: { inner: 'invalid string' }
        } )

        assert_equal 1, errors.length
        assert_equal 'outer/inner', errors[ 0 ].keypath
      end

      def test_error_path_for_array_element
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        errors = builder.validate( {
          items: [
            { value: 123 },
            'invalid string',
            { value: 456 }
          ]
        } )

        assert_equal 1, errors.length
        assert_equal 'items', errors[ 0 ].keypath
      end

      def test_error_path_for_nested_object_in_array
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true do
            value Integer
          end
        end

        errors = builder.validate( {
          items: [
            { value: 123 },
            { value: 'not an integer' }
          ]
        } )

        assert_equal 1, errors.length
        assert_equal 'items/value', errors[ 0 ].keypath
      end

      def test_multiple_errors_at_different_paths
        builder = build_schema do
          first [ Object, TrueClass, FalseClass ] do
            value Integer
          end
          second [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        errors = builder.validate( {
          first: 'invalid',
          second: { value: 'also invalid' }
        } )

        assert_equal 2, errors.length
        keypaths = errors.map( &:keypath ).sort
        assert_equal [ 'first', 'second/value' ], keypaths
      end

      def test_error_for_required_nested_field
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value Integer, required: true
          end
        end

        errors = builder.validate( { data: {} } )

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]
        assert_equal 'data/value', errors[ 0 ].keypath
      end

      def test_error_for_in_option_in_nested
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            status Symbol, in: [ :active, :inactive ]
          end
        end

        errors = builder.validate( { data: { status: :unknown } } )

        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]
        assert_equal 'data/status', errors[ 0 ].keypath
      end

      def test_error_types_array_shown_in_message
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        errors = builder.validate( { data: 123 } )

        assert_equal 1, errors.length
        assert_includes errors[ 0 ].message, 'TrueClass'
        assert_includes errors[ 0 ].message, 'FalseClass'
      end

      def test_build_bang_raises_for_invalid_scalar
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        assert_raises DynamicSchema::IncompatibleTypeError do
          builder.build! { data 'invalid' }
        end
      end

      def test_build_bang_raises_for_invalid_nested
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value Integer
          end
        end

        assert_raises DynamicSchema::IncompatibleTypeError do
          builder.build! do
            data { value 'not an integer' }
          end
        end
      end

    end

  end
end
