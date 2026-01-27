require_relative '../test_helper'

module StructTests
  module Validation

    class BuildBangTest < Minitest::Test

      def test_build_bang_validates
        person_class = DynamicSchema::Struct.define do
          name String
          age Integer
        end

        assert_raises DynamicSchema::IncompatibleTypeError do
          person_class.build!( name: 'Alice', age: 'not-an-integer' )
        end
      end

      def test_build_bang_passes_valid
        person_class = DynamicSchema::Struct.define do
          name String
          age Integer
        end

        person = person_class.build!( name: 'Valid', quantity: 99 )
        # should not raise
        assert person
      end
    end

    class BuildTest < Minitest::Test

      def test_build_does_not_validate_immediately
        person_class = DynamicSchema::Struct.define do
          name String
          age Integer
        end

        # should not raise
        person = person_class.build( name: 'Bob', age: 'not-an-integer' )
        assert_nil person.age
      end

      def test_build_exposes_validation_helpers
        person_class = DynamicSchema::Struct.define do
          name String
          age Integer
        end

        person = person_class.build( name: 'Bob', age: 'not-an-integer' )

        refute person.valid?
        assert person.validate.all? { | e | e.is_a?( DynamicSchema::Error ) }
        assert_raises( DynamicSchema::IncompatibleTypeError ) { person.validate! }
      end
    end

    class ValidMethodTest < Minitest::Test

      def test_valid_returns_true_for_valid_instance
        person_class = DynamicSchema::Struct.define do
          name String
          age Integer
        end

        person = person_class.build( name: 'Alice', age: 30 )
        assert person.valid?
      end

      def test_valid_returns_false_for_invalid_instance
        person_class = DynamicSchema::Struct.define do
          age Integer
        end

        person = person_class.build( age: 'not-an-integer' )
        refute person.valid?
      end
    end

    class ValidateMethodTest < Minitest::Test

      def test_validate_returns_empty_array_when_valid
        person_class = DynamicSchema::Struct.define do
          name String
        end

        person = person_class.build( name: 'Alice' )
        assert_empty person.validate
      end

      def test_validate_returns_errors_array
        person_class = DynamicSchema::Struct.define do
          age Integer
        end

        person = person_class.build( age: 'nan' )
        errors = person.validate

        refute_empty errors
        assert errors.all? { | e | e.is_a?( DynamicSchema::Error ) }
      end
    end

    class ValidateBangMethodTest < Minitest::Test

      def test_validate_bang_raises_on_first_error
        person_class = DynamicSchema::Struct.define do
          age Integer
        end

        person = person_class.build( age: 'nan' )

        assert_raises DynamicSchema::IncompatibleTypeError do
          person.validate!
        end
      end

      def test_validate_bang_does_not_raise_when_valid
        person_class = DynamicSchema::Struct.define do
          name String
        end

        person = person_class.build( name: 'Alice' )
        person.validate!  # should not raise
      end
    end

    class NestedValidationTest < Minitest::Test

      def test_validates_required_nested_object
        account_class = DynamicSchema::Struct.define do
          profile required: true do
            username String
          end
        end

        missing = account_class.build
        refute missing.valid?

        errors = missing.validate
        assert errors.any? { | e | e.is_a?( DynamicSchema::RequiredOptionError ) }
      end

      def test_validates_types_in_nested_object
        account_class = DynamicSchema::Struct.define do
          profile do
            age Integer
          end
        end

        wrong_type = account_class.build( profile: { age: 'not-an-integer' } )
        refute wrong_type.valid?

        assert_raises DynamicSchema::IncompatibleTypeError do
          wrong_type.validate!
        end
      end

      def test_validates_in_option_in_nested_object
        settings_class = DynamicSchema::Struct.define do
          preferences do
            state Symbol, in: [ :on, :off ]
          end
        end

        instance = settings_class.build( preferences: { state: 'maybe' } )
        errors = instance.validate

        refute_empty errors
        assert_instance_of DynamicSchema::InOptionError, errors.first
      end
    end

    class ArrayValidationTest < Minitest::Test

      def test_validates_each_element_in_array
        catalog_class = DynamicSchema::Struct.define do
          products array: true do
            price Integer
          end
        end

        invalid = catalog_class.build( products: [ { price: 1 }, { price: 'two' } ] )
        refute invalid.valid?

        assert_raises DynamicSchema::IncompatibleTypeError do
          invalid.validate!
        end
      end

      def test_valid_array_passes
        catalog_class = DynamicSchema::Struct.define do
          products array: true do
            price Integer
          end
        end

        valid = catalog_class.build( products: [ { price: 1 }, { price: 2 } ] )
        assert valid.valid?
        assert_empty valid.validate
      end
    end

  end

end
