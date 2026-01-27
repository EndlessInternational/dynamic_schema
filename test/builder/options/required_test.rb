require_relative '../../test_helper'

module Builder
  module Options

    class RequiredTest < Minitest::Test
      include TestHelper

      def test_validates_required_field_present
        builder = build_schema do
          api_key String, required: true
        end

        result = builder.build! { api_key 'secret' }
        assert_equal 'secret', result[ :api_key ]
      end

      def test_raises_when_required_field_missing
        builder = build_schema do
          api_key String, required: true
        end

        assert_raises DynamicSchema::RequiredOptionError do
          builder.build! {}
        end
      end

      def test_required_with_default_is_valid
        builder = build_schema do
          version String, required: true, default: '1.0'
        end

        result = builder.build! {}
        assert_equal '1.0', result[ :version ]
      end

      def test_required_nested_field
        builder = build_schema do
          user do
            name String, required: true
          end
        end

        result = builder.build! do
          user { name 'Alice' }
        end

        assert_equal 'Alice', result[ :user ][ :name ]
      end

      def test_raises_for_missing_nested_required_field
        builder = build_schema do
          user do
            name String, required: true
          end
        end

        assert_raises DynamicSchema::RequiredOptionError do
          builder.build! { user {} }
        end
      end

      def test_nested_required_only_checked_when_parent_present
        builder = build_schema do
          settings do
            theme String, required: true
          end
        end

        # does not raise when parent not present
        result = builder.build! {}
        assert_nil result[ :settings ]
      end
    end

  end
end
