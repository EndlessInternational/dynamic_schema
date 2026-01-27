require_relative '../../test_helper'

module Builder
  module Options

    class NormalizeTest < Minitest::Test
      include TestHelper

      def test_normalizes_scalar_value_with_lambda
        builder = build_schema do
          name String, normalize: ->( v ) { v.upcase }
        end

        result = builder.build { name 'alice' }
        assert_equal 'ALICE', result[ :name ]
      end

      def test_normalizes_scalar_value_with_proc
        upcase_proc = Proc.new { | v | v.upcase }
        builder = build_schema do
          name String, normalize: upcase_proc
        end

        result = builder.build { name 'bob' }
        assert_equal 'BOB', result[ :name ]
      end

      def test_normalizes_integer_value
        builder = build_schema do
          count Integer, normalize: ->( v ) { v * 2 }
        end

        result = builder.build { count 5 }
        assert_equal 10, result[ :count ]
      end

      def test_normalizes_value_after_type_coercion
        builder = build_schema do
          count Integer, normalize: ->( v ) { v + 100 }
        end

        result = builder.build { count '5' }
        assert_equal 105, result[ :count ]
      end

      def test_normalize_with_hash_initialization
        builder = build_schema do
          name String, normalize: ->( v ) { v.upcase }
        end

        result = builder.build( { name: 'alice' } )
        assert_equal 'ALICE', result[ :name ]
      end

      def test_normalize_without_type
        builder = build_schema do
          value normalize: ->( v ) { v.to_s.upcase }
        end

        result = builder.build { value 'test' }
        assert_equal 'TEST', result[ :value ]
      end

      def test_no_normalize_when_value_is_nil
        normalize_called = false
        builder = build_schema do
          name String, normalize: ->( v ) {
            normalize_called = true
            v
          }
        end

        builder.build {}
        refute normalize_called
      end
    end

  end
end
