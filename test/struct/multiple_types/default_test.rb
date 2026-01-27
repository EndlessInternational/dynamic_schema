require_relative '../../test_helper'

module StructTests
  module MultipleTypes

    class DefaultTest < Minitest::Test

      def test_with_default_hash
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ], default: { name: 'default' } do
            name String
          end
        end

        instance = struct_class.build

        assert_equal 'default', instance.config.name
      end

      def test_with_default_boolean
        struct_class = DynamicSchema::Struct.define do
          enabled [ Object, TrueClass, FalseClass ], default: false do
            level Integer
          end
        end

        instance = struct_class.build

        assert_equal false, instance.enabled
      end

      def test_array_default
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true, default: [] do
            name String
          end
        end

        instance = struct_class.build

        assert_equal [], instance.items
      end

    end

  end
end
