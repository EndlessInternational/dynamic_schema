require_relative '../../test_helper'

module Builder
  module Objects

    class ArgumentsTest < Minitest::Test
      include TestHelper

      def test_single_argument
        builder = build_schema do
          item arguments: :name do
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

      def test_argument_only_no_block
        builder = build_schema do
          item arguments: :value do
            value
          end
        end

        result = builder.build do
          item :one
        end

        assert_equal :one, result[ :item ][ :value ]
      end

      def test_multiple_arguments
        builder = build_schema do
          point arguments: [ :x, :y ] do
            x Integer
            y Integer
          end
        end

        result = builder.build do
          point 10, 20
        end

        assert_equal 10, result[ :point ][ :x ]
        assert_equal 20, result[ :point ][ :y ]
      end

      def test_arguments_with_additional_block_values
        builder = build_schema do
          item arguments: [ :name, :price ] do
            name String
            price Integer
            quantity Integer
          end
        end

        result = builder.build do
          item 'Widget', 100 do
            quantity 5
          end
        end

        assert_equal 'Widget', result[ :item ][ :name ]
        assert_equal 100, result[ :item ][ :price ]
        assert_equal 5, result[ :item ][ :quantity ]
      end

      def test_arguments_with_hash_attributes
        builder = build_schema do
          item arguments: [ :name, :price ] do
            name String
            price Integer
            quantity Integer
            description String
          end
        end

        result = builder.build! do
          item 'Widget', 100, quantity: 5 do
            description 'A useful widget'
          end
        end

        assert_equal 'Widget', result[ :item ][ :name ]
        assert_equal 100, result[ :item ][ :price ]
        assert_equal 5, result[ :item ][ :quantity ]
        assert_equal 'A useful widget', result[ :item ][ :description ]
      end

      def test_argument_value_is_array
        builder = build_schema do
          item arguments: :values do
            values array: true
          end
        end

        result = builder.build do
          item [ :one, :two ]
        end

        assert_equal [ :one, :two ], result[ :item ][ :values ]
      end

      def test_both_arguments_are_arrays
        builder = build_schema do
          item arguments: [ :first, :second ] do
            first array: true
            second array: true
          end
        end

        result = builder.build do
          item [ :a, :b ], [ :c, :d ]
        end

        assert_equal [ :a, :b ], result[ :item ][ :first ]
        assert_equal [ :c, :d ], result[ :item ][ :second ]
      end
    end

  end
end
