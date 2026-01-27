require_relative '../test_helper'

module Builder

  # tests for build method with various input combinations
  class BuildInputsTest < Minitest::Test
    include TestHelper

    def test_build_with_only_block
      builder = build_schema do
        name String
        count Integer
      end

      result = builder.build do
        name 'test'
        count 42
      end

      assert_equal 'test', result[ :name ]
      assert_equal 42, result[ :count ]
    end

    def test_build_with_only_initial_values
      builder = build_schema do
        name String
        count Integer
      end

      result = builder.build( { name: 'from-hash', count: 100 } )

      assert_equal 'from-hash', result[ :name ]
      assert_equal 100, result[ :count ]
    end

    def test_build_with_initial_values_and_block
      builder = build_schema do
        name String
        count Integer
      end

      result = builder.build( { name: 'from-hash' } ) do
        count 200
      end

      assert_equal 'from-hash', result[ :name ]
      assert_equal 200, result[ :count ]
    end

    def test_block_overrides_initial_values
      builder = build_schema do
        name String
      end

      result = builder.build( { name: 'from-hash' } ) do
        name 'from-block'
      end

      assert_equal 'from-block', result[ :name ]
    end

    def test_build_with_empty_block
      builder = build_schema do
        name String, default: 'default-value'
      end

      result = builder.build {}

      assert_equal 'default-value', result[ :name ]
    end

    def test_build_with_empty_hash
      builder = build_schema do
        name String, default: 'default-value'
      end

      result = builder.build( {} )

      assert_equal 'default-value', result[ :name ]
    end

    def test_build_with_nil
      builder = build_schema do
        name String, default: 'default-value'
      end

      result = builder.build( nil )

      assert_equal 'default-value', result[ :name ]
    end

    def test_build_without_arguments
      builder = build_schema do
        name String, default: 'default-value'
      end

      result = builder.build

      assert_equal 'default-value', result[ :name ]
    end

  end

  # tests for defaults option in build
  class BuildDefaultsOptionTest < Minitest::Test
    include TestHelper

    def test_defaults_true_applies_defaults
      builder = build_schema do
        version String, default: '1.0'
      end

      result = builder.build( defaults: true )

      assert_equal '1.0', result[ :version ]
    end

    def test_defaults_false_skips_defaults
      builder = build_schema do
        version String, default: '1.0'
      end

      result = builder.build( defaults: false )

      assert_nil result[ :version ]
    end

    def test_defaults_option_with_initial_values
      builder = build_schema do
        name String
        version String, default: '1.0'
      end

      result = builder.build( { name: 'test' }, defaults: false )

      assert_equal 'test', result[ :name ]
      assert_nil result[ :version ]
    end

    def test_explicit_value_overrides_default
      builder = build_schema do
        version String, default: '1.0'
      end

      result = builder.build( { version: '2.0' } )

      assert_equal '2.0', result[ :version ]
    end

  end

  # tests for nested objects in build
  class BuildNestedObjectsTest < Minitest::Test
    include TestHelper

    def test_nested_object_via_block
      builder = build_schema do
        database do
          host String
          port Integer
        end
      end

      result = builder.build do
        database do
          host 'localhost'
          port 5432
        end
      end

      assert_equal 'localhost', result[ :database ][ :host ]
      assert_equal 5432, result[ :database ][ :port ]
    end

    def test_nested_object_via_initial_values
      builder = build_schema do
        database do
          host String
          port Integer
        end
      end

      result = builder.build( { database: { host: 'localhost', port: 5432 } } )

      assert_equal 'localhost', result[ :database ][ :host ]
      assert_equal 5432, result[ :database ][ :port ]
    end

    def test_nested_object_partial_via_initial_and_block
      builder = build_schema do
        database do
          host String
          port Integer
        end
      end

      result = builder.build( { database: { host: 'localhost' } } ) do
        database do
          port 5432
        end
      end

      assert_equal 'localhost', result[ :database ][ :host ]
      assert_equal 5432, result[ :database ][ :port ]
    end

  end

end
