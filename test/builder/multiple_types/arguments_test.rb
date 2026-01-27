require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class ArgumentsTest < Minitest::Test
      include TestHelper

      def test_single_argument_with_object_value
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ], arguments: :name do
            name String
            quantity Integer
          end
        end

        result = builder.build do
          item 'Widget' do
            quantity 5
          end
        end

        assert_equal 'Widget', result[ :item ][ :name ]
        assert_equal 5, result[ :item ][ :quantity ]
      end

      def test_single_argument_with_scalar_value
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ], arguments: :name do
            name String
            quantity Integer
          end
        end

        result = builder.build do
          item true
        end

        assert_equal true, result[ :item ]
      end

      def test_multiple_arguments_with_object_value
        builder = build_schema do
          point [ Object, TrueClass, FalseClass ], arguments: [ :x, :y ] do
            x Integer
            y Integer
            label String
          end
        end

        result = builder.build do
          point 10, 20 do
            label 'origin'
          end
        end

        assert_equal 10, result[ :point ][ :x ]
        assert_equal 20, result[ :point ][ :y ]
        assert_equal 'origin', result[ :point ][ :label ]
      end

      def test_multiple_arguments_with_scalar_value
        builder = build_schema do
          point [ Object, TrueClass, FalseClass ], arguments: [ :x, :y ] do
            x Integer
            y Integer
          end
        end

        result = builder.build do
          point false
        end

        assert_equal false, result[ :point ]
      end

      def test_hash_input_without_arguments
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ] do
            name String
            quantity Integer
          end
        end

        result = builder.build do
          item( { name: 'Widget', quantity: 10 } )
        end

        assert_equal 'Widget', result[ :item ][ :name ]
        assert_equal 10, result[ :item ][ :quantity ]
      end

      def test_array_with_arguments
        builder = build_schema do
          items [ Object, TrueClass, FalseClass ], array: true, arguments: :name do
            name String
            value Integer
          end
        end

        result = builder.build do
          items 'first' do
            value 1
          end
          items true
          items 'second' do
            value 2
          end
        end

        assert_equal 3, result[ :items ].length
        assert_equal 'first', result[ :items ][ 0 ][ :name ]
        assert_equal 1, result[ :items ][ 0 ][ :value ]
        assert_equal true, result[ :items ][ 1 ]
        assert_equal 'second', result[ :items ][ 2 ][ :name ]
        assert_equal 2, result[ :items ][ 2 ][ :value ]
      end

      def test_nested_with_arguments
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ], arguments: :id do
            id String
            inner [ Object, TrueClass, FalseClass ], arguments: :name do
              name String
              value Integer
            end
          end
        end

        result = builder.build do
          outer 'outer-1' do
            inner 'inner-1' do
              value 42
            end
          end
        end

        assert_equal 'outer-1', result[ :outer ][ :id ]
        assert_equal 'inner-1', result[ :outer ][ :inner ][ :name ]
        assert_equal 42, result[ :outer ][ :inner ][ :value ]
      end

      def test_nested_outer_object_inner_scalar
        builder = build_schema do
          outer [ Object, TrueClass, FalseClass ], arguments: :id do
            id String
            inner [ Object, TrueClass, FalseClass ], arguments: :name do
              name String
            end
          end
        end

        result = builder.build do
          outer 'outer-1' do
            inner false
          end
        end

        assert_equal 'outer-1', result[ :outer ][ :id ]
        assert_equal false, result[ :outer ][ :inner ]
      end

      def test_validates_with_arguments
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ], arguments: :name do
            name String
            value Integer
          end
        end

        result = builder.build do
          item 'test' do
            value 123
          end
        end

        assert builder.valid?( result )
      end

      def test_validates_scalar_with_arguments
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ], arguments: :name do
            name String
            value Integer
          end
        end

        result = builder.build do
          item true
        end

        assert builder.valid?( result )
      end

      def test_invalid_scalar_type_with_arguments
        builder = build_schema do
          item [ Object, TrueClass, FalseClass ], arguments: :name do
            name String
          end
        end

        result = builder.build do
          item 'invalid string'
        end

        refute builder.valid?( result )
      end

    end

  end
end
