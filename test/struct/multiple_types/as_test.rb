require_relative '../../test_helper'

module StructTests
  module MultipleTypes

    class AsTest < Minitest::Test

      def test_with_as_option_using_object
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ], as: :configuration do
            timeout Integer
          end
        end

        instance = struct_class.build( configuration: { timeout: 30 } )

        assert_equal 30, instance.config.timeout
      end

      def test_with_as_option_using_boolean
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ], as: :configuration do
            timeout Integer
          end
        end

        instance = struct_class.build( configuration: true )

        assert_equal true, instance.config
      end

      def test_array_with_as_option
        struct_class = DynamicSchema::Struct.define do
          items [ Object, TrueClass, FalseClass ], array: true, as: :elements do
            name String
          end
        end

        instance = struct_class.build( elements: [ true, { name: 'test' } ] )

        assert_equal 2, instance.items.length
        assert_equal true, instance.items[ 0 ]
        assert_equal 'test', instance.items[ 1 ].name
      end

      def test_to_h_with_as_option
        struct_class = DynamicSchema::Struct.define do
          config [ Object, TrueClass, FalseClass ], as: :configuration do
            timeout Integer
          end
        end

        instance = struct_class.build( configuration: { timeout: 30 } )
        result = instance.to_h

        assert_equal( { timeout: 30 }, result[ :configuration ] )
      end

    end

  end
end
