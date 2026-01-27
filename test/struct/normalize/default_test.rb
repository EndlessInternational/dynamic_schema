require_relative '../../test_helper'

module StructTests
  module Normalize

    class DefaultTest < Minitest::Test
      include TestHelper

      def test_normalizes_default_value
        klass = DynamicSchema::Struct.define do
          name String, default: 'default', normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( {} )
        assert_equal 'DEFAULT', struct.name
      end

      def test_normalizes_overridden_default_value
        klass = DynamicSchema::Struct.define do
          name String, default: 'default', normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( name: 'custom' )
        assert_equal 'CUSTOM', struct.name
      end

      def test_normalizes_default_array_value
        klass = DynamicSchema::Struct.define do
          tags String, array: true, default: [ 'one', 'two' ], normalize: ->( v ) { v.upcase }
        end

        struct = klass.build( {} )
        assert_equal [ 'ONE', 'TWO' ], struct.tags
      end
    end

  end
end
