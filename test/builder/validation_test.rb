require_relative '../test_helper'

module Builder

  class ValidateBangTest < Minitest::Test
    include TestHelper

    def test_raises_for_incompatible_type
      builder = build_schema do
        count Integer
      end

      assert_raises DynamicSchema::IncompatibleTypeError do
        builder.build! { count 'not-a-number' }
      end
    end

    def test_passes_for_correct_type
      builder = build_schema do
        count Integer
      end

      result = builder.build! { count 42 }
      assert_equal 42, result[ :count ]
    end

    def test_validates_nested_types
      builder = build_schema do
        user do
          age Integer
        end
      end

      assert_raises DynamicSchema::IncompatibleTypeError do
        builder.build! do
          user { age 'not-a-number' }
        end
      end
    end

    def test_raises_for_missing_required_field
      builder = build_schema do
        api_key String, required: true
      end

      assert_raises DynamicSchema::RequiredOptionError do
        builder.build! {}
      end
    end

    def test_raises_for_value_not_in_array
      builder = build_schema do
        status Symbol, in: [ :active, :inactive ]
      end

      assert_raises DynamicSchema::InOptionError do
        builder.build! { status :unknown }
      end
    end

    def test_raises_for_value_outside_range
      builder = build_schema do
        temperature Float, in: 0..1
      end

      assert_raises DynamicSchema::InOptionError do
        builder.build! { temperature 2.0 }
      end
    end
  end

  class ValidateTest < Minitest::Test
    include TestHelper

    def test_returns_empty_array_when_valid
      builder = build_schema do
        value Integer
      end

      errors = builder.validate( { value: 42 } )
      assert_empty errors
    end

    def test_returns_errors_for_type_mismatch
      builder = build_schema do
        value Integer
      end

      errors = builder.validate( { value: 'nan' } )
      assert_equal 1, errors.length
      assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
    end

    def test_returns_errors_for_required_missing
      builder = build_schema do
        value required: true
      end

      errors = builder.validate( {} )
      assert_equal 1, errors.length
      assert_instance_of DynamicSchema::RequiredOptionError, errors[ 0 ]
    end

    def test_returns_errors_for_in_violation
      builder = build_schema do
        value Symbol, in: [ :one, :two, :three ]
      end

      errors = builder.validate( { value: :zero } )
      assert_equal 1, errors.length
      assert_instance_of DynamicSchema::InOptionError, errors[ 0 ]
    end

    def test_collects_multiple_errors
      builder = build_schema do
        required_value required: true
        typed_value Integer
        in_value Symbol, in: [ :a, :b ]
      end

      errors = builder.validate( { typed_value: 'nan', in_value: :c } )
      assert_equal 3, errors.length
    end

    def test_validates_nested_objects
      builder = build_schema do
        settings do
          value Integer
        end
      end

      errors = builder.validate( { settings: { value: 'nan' } } )
      assert_equal 1, errors.length
      assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
    end

    def test_validates_array_objects
      builder = build_schema do
        items array: true do
          value Integer
        end
      end

      errors = builder.validate( { items: [ { value: 'nan' } ] } )
      assert_equal 1, errors.length
      assert_instance_of DynamicSchema::IncompatibleTypeError, errors[ 0 ]
    end
  end

  class ValidTest < Minitest::Test
    include TestHelper

    def test_returns_true_when_valid
      builder = build_schema do
        value Integer
      end

      assert builder.valid?( { value: 42 } )
    end

    def test_returns_false_for_type_mismatch
      builder = build_schema do
        value Integer
      end

      refute builder.valid?( { value: 'nan' } )
    end

    def test_returns_false_for_required_missing
      builder = build_schema do
        value required: true
      end

      refute builder.valid?( {} )
    end

    def test_returns_false_for_in_violation
      builder = build_schema do
        value Integer, in: 1..10
      end

      refute builder.valid?( { value: 0 } )
    end

    def test_returns_true_for_empty_hash_with_optional_fields
      builder = build_schema do
        optional_value Integer
      end

      assert builder.valid?( {} )
    end
  end

  class BuildVsBuildBangTest < Minitest::Test
    include TestHelper

    def test_build_does_not_validate
      builder = build_schema do
        value Integer, required: true
      end

      # build without validation - no error raised
      result = builder.build {}
      assert_nil result[ :value ]
    end

    def test_build_bang_validates
      builder = build_schema do
        value Integer, required: true
      end

      # build! with validation - error raised
      assert_raises DynamicSchema::RequiredOptionError do
        builder.build! {}
      end
    end
  end

end
