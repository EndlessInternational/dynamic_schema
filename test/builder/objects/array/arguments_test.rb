require_relative '../../../test_helper'

module Builder
  module Objects
    module Array

      class ArgumentsTest < Minitest::Test
        include TestHelper

        def test_array_objects_with_single_argument
          builder = build_schema do
            item arguments: :value, array: true do
              value
            end
          end

          result = builder.build do
            item :one
            item :two
          end

          assert_equal 2, result[ :item ].length
          assert_equal :one, result[ :item ][ 0 ][ :value ]
          assert_equal :two, result[ :item ][ 1 ][ :value ]
        end

        def test_array_objects_with_multiple_arguments
          builder = build_schema do
            point arguments: [ :x, :y ], array: true do
              x Integer
              y Integer
            end
          end

          result = builder.build do
            point 0, 0
            point 10, 20
          end

          assert_equal 2, result[ :point ].length
          assert_equal 0, result[ :point ][ 0 ][ :x ]
          assert_equal 0, result[ :point ][ 0 ][ :y ]
          assert_equal 10, result[ :point ][ 1 ][ :x ]
          assert_equal 20, result[ :point ][ 1 ][ :y ]
        end

        def test_array_objects_with_arguments_and_block
          builder = build_schema do
            message arguments: :role, array: true do
              role Symbol
              content String
            end
          end

          result = builder.build do
            message :system do
              content 'You are helpful.'
            end
            message :user do
              content 'Hello!'
            end
          end

          assert_equal 2, result[ :message ].length
          assert_equal :system, result[ :message ][ 0 ][ :role ]
          assert_equal 'You are helpful.', result[ :message ][ 0 ][ :content ]
          assert_equal :user, result[ :message ][ 1 ][ :role ]
          assert_equal 'Hello!', result[ :message ][ 1 ][ :content ]
        end

        def test_array_objects_with_arguments_and_hash_and_block
          builder = build_schema do
            item arguments: [ :name, :price ], array: true do
              name String
              price Integer
              quantity Integer
              note String
            end
          end

          result = builder.build! do
            item 'Widget', 100, quantity: 5 do
              note 'first item'
            end
            item 'Gadget', 200, quantity: 3 do
              note 'second item'
            end
          end

          assert_equal 2, result[ :item ].length
          assert_equal 'Widget', result[ :item ][ 0 ][ :name ]
          assert_equal 100, result[ :item ][ 0 ][ :price ]
          assert_equal 5, result[ :item ][ 0 ][ :quantity ]
          assert_equal 'first item', result[ :item ][ 0 ][ :note ]
          assert_equal 'Gadget', result[ :item ][ 1 ][ :name ]
          assert_equal 200, result[ :item ][ 1 ][ :price ]
          assert_equal 3, result[ :item ][ 1 ][ :quantity ]
          assert_equal 'second item', result[ :item ][ 1 ][ :note ]
        end

        def test_array_objects_with_arguments_and_as
          builder = build_schema do
            message arguments: :role, as: :messages, array: true do
              role Symbol
              content String
            end
          end

          result = builder.build do
            message :system do
              content 'Hello'
            end
            message :user do
              content 'Hi'
            end
          end

          assert_equal 2, result[ :messages ].length
          assert_nil result[ :message ]
          assert_equal :system, result[ :messages ][ 0 ][ :role ]
          assert_equal :user, result[ :messages ][ 1 ][ :role ]
        end
      end

    end
  end
end
