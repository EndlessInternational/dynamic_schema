require_relative '../../test_helper'

module Builder
  module Validation

    # tests for error keypath tracking in nested schemas
    class ErrorPathsTest < Minitest::Test
      include TestHelper

      def test_top_level_error_has_simple_keypath
        builder = build_schema do
          value Integer
        end

        errors = builder.validate( { value: 'nan' } )

        assert_equal 1, errors.length
        assert_equal 'value', errors[ 0 ].keypath
        assert_equal :value, errors[ 0 ].key
      end

      def test_nested_error_has_path_with_parent
        builder = build_schema do
          settings do
            timeout Integer
          end
        end

        errors = builder.validate( { settings: { timeout: 'nan' } } )

        assert_equal 1, errors.length
        assert_equal 'settings/timeout', errors[ 0 ].keypath
        assert_equal :timeout, errors[ 0 ].key
      end

      def test_deeply_nested_error_has_full_path
        builder = build_schema do
          level1 do
            level2 do
              level3 do
                value Integer
              end
            end
          end
        end

        errors = builder.validate( { level1: { level2: { level3: { value: 'nan' } } } } )

        assert_equal 1, errors.length
        assert_equal 'level1/level2/level3/value', errors[ 0 ].keypath
      end

      def test_array_object_error_includes_path
        builder = build_schema do
          items array: true do
            count Integer
          end
        end

        errors = builder.validate( { items: [ { count: 1 }, { count: 'nan' } ] } )

        assert_equal 1, errors.length
        assert_includes errors[ 0 ].keypath, 'count'
      end

      def test_required_error_has_correct_keypath
        builder = build_schema do
          config do
            api_key required: true
          end
        end

        errors = builder.validate( { config: {} } )

        assert_equal 1, errors.length
        assert_equal 'config/api_key', errors[ 0 ].keypath
      end

      def test_in_option_error_has_correct_keypath
        builder = build_schema do
          settings do
            mode Symbol, in: [ :fast, :slow ]
          end
        end

        errors = builder.validate( { settings: { mode: :unknown } } )

        assert_equal 1, errors.length
        assert_equal 'settings/mode', errors[ 0 ].keypath
      end

    end

    # tests for combined validation options
    class CombinedOptionsTest < Minitest::Test
      include TestHelper

      def test_required_and_type_both_fail
        builder = build_schema do
          required_typed Integer, required: true
        end

        # missing value - required error
        errors = builder.validate( {} )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]
      end

      def test_required_passes_type_fails
        builder = build_schema do
          required_typed Integer, required: true
        end

        # value present but wrong type
        errors = builder.validate( { required_typed: 'nan' } )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
      end

      def test_in_option_takes_precedence_over_type
        # note: when both type and in: are specified, validator only checks in:
        builder = build_schema do
          constrained Integer, in: 1..10
        end

        # wrong type - but in option is checked instead of type
        errors = builder.validate( { constrained: 'nan' } )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]

        # out of range
        errors = builder.validate( { constrained: 99 } )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]

        # valid
        errors = builder.validate( { constrained: 5 } )
        assert_empty errors
      end

      def test_required_checked_before_in_option
        # note: required is checked first, then in: option
        builder = build_schema do
          fully_constrained Integer, required: true, in: [ 1, 2, 3 ]
        end

        # missing - required error
        errors = builder.validate( {} )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]

        # present but not in list
        errors = builder.validate( { fully_constrained: 99 } )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]

        # valid
        errors = builder.validate( { fully_constrained: 2 } )
        assert_empty errors
      end

    end

    # tests for nil value handling
    class NilValueTest < Minitest::Test
      include TestHelper

      def test_nil_value_with_type_passes_when_not_required
        builder = build_schema do
          optional_value Integer
        end

        errors = builder.validate( { optional_value: nil } )
        assert_empty errors
      end

      def test_nil_value_with_required_fails
        builder = build_schema do
          required_value Integer, required: true
        end

        errors = builder.validate( { required_value: nil } )
        assert_equal 1, errors.length
        assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]
      end

      def test_nil_value_with_in_option_passes_when_not_required
        builder = build_schema do
          optional_constrained Symbol, in: [ :a, :b ]
        end

        errors = builder.validate( { optional_constrained: nil } )
        assert_empty errors
      end

    end

  end

end
