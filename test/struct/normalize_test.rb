require_relative '../test_helper'

module StructTests
  module Normalize

    class BasicTest < Minitest::Test
      include TestHelper

      def test_normalizes_scalar_value
        klass = DynamicSchema::Struct.define do
          name String, normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( name: 'alice' )
        assert_equal 'ALICE', struct.name
      end

      def test_normalizes_integer_value
        klass = DynamicSchema::Struct.define do
          count Integer, normalize: ->( v ) { v * 2 }
        end

        struct = klass.build( count: 5 )
        assert_equal 10, struct.count
      end

      def test_normalizes_value_after_type_coercion
        klass = DynamicSchema::Struct.define do
          count Integer, normalize: ->( v ) { v + 100 }
        end

        struct = klass.build( count: '5' )
        assert_equal 105, struct.count
      end

      def test_normalize_without_type
        klass = DynamicSchema::Struct.define do
          value normalize: ->( v ) { v.to_s.upcase }
        end

        struct = klass.build( value: 'test' )
        assert_equal 'TEST', struct.value
      end

      def test_no_normalize_when_value_is_nil
        normalize_called = false
        klass = DynamicSchema::Struct.define do
          name String, normalize: ->( v ) {
            normalize_called = true
            v
          }
        end

        klass.build( {} ).name
        refute normalize_called
      end

      def test_normalized_value_is_cached
        call_count = 0
        klass = DynamicSchema::Struct.define do
          name String, normalize: ->( v ) {
            call_count += 1
            v.upcase
          }
        end

        struct = klass.build( name: 'alice' )
        3.times { struct.name }
        assert_equal 1, call_count
      end
    end

  end
end
