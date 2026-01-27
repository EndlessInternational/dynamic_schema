require_relative '../../test_helper'

module Builder
  module Options

    class DefaultTest < Minitest::Test
      include TestHelper

      def test_uses_default_when_not_provided
        builder = build_schema do
          version String, default: '1.0'
        end

        result = builder.build {}
        assert_equal '1.0', result[ :version ]
      end

      def test_overrides_default_when_provided
        builder = build_schema do
          version String, default: '1.0'
        end

        result = builder.build { version '2.0' }
        assert_equal '2.0', result[ :version ]
      end

      def test_default_with_integer
        builder = build_schema do
          timeout Integer, default: 30
        end

        result = builder.build {}
        assert_equal 30, result[ :timeout ]
      end

      def test_default_with_float
        builder = build_schema do
          rate Float, default: 0.5
        end

        result = builder.build {}
        assert_equal 0.5, result[ :rate ]
      end

      def test_default_with_boolean_false
        builder = build_schema do
          enabled [ TrueClass, FalseClass ], default: false
        end

        result = builder.build {}
        assert_equal false, result[ :enabled ]
      end

      def test_default_with_boolean_true
        builder = build_schema do
          enabled [ TrueClass, FalseClass ], default: true
        end

        result = builder.build {}
        assert_equal true, result[ :enabled ]
      end

      def test_default_array_value
        builder = build_schema do
          roles String, array: true, default: [ 'user', 'admin' ]
        end

        result = builder.build {}
        assert_equal [ 'user', 'admin' ], result[ :roles ]
      end

      def test_overrides_default_array
        builder = build_schema do
          roles String, array: true, default: [ 'user', 'admin' ]
        end

        result = builder.build { roles [ 'editor' ] }
        assert_equal [ 'editor' ], result[ :roles ]
      end

      def test_nested_defaults
        builder = build_schema do
          settings do
            theme String, default: 'dark'
            timeout Integer, default: 60
          end
        end

        result = builder.build { settings {} }
        assert_equal 'dark', result[ :settings ][ :theme ]
        assert_equal 60, result[ :settings ][ :timeout ]
      end

      def test_partial_override_of_nested_defaults
        builder = build_schema do
          settings do
            theme String, default: 'dark'
            timeout Integer, default: 60
          end
        end

        result = builder.build do
          settings { theme 'light' }
        end

        assert_equal 'light', result[ :settings ][ :theme ]
        assert_equal 60, result[ :settings ][ :timeout ]
      end
    end

    class DefaultDisabledTest < Minitest::Test
      include TestHelper

      def test_builds_without_defaults
        builder = build_schema do
          version String, default: '1.0'
        end

        result = builder.build( nil, defaults: false ) {}
        assert_nil result[ :version ]
      end

      def test_nested_defaults_disabled
        builder = build_schema do
          settings do
            theme String, default: 'dark'
          end
        end

        result = builder.build( nil, defaults: false ) do
          settings {}
        end

        assert_nil result[ :settings ][ :theme ]
      end
    end

  end
end
