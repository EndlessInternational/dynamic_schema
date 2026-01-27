require_relative '../../test_helper'

module Builder
  module Options

    class AsTest < Minitest::Test
      include TestHelper

      def test_maps_value_to_different_key
        builder = build_schema do
          content_type String, as: 'Content-Type', default: 'application/json'
        end

        result = builder.build {}
        assert_equal 'application/json', result[ 'Content-Type' ]
        assert_nil result[ :content_type ]
      end

      def test_maps_symbol_key
        builder = build_schema do
          api_key String, as: :authorization
        end

        result = builder.build { api_key 'Bearer token' }
        assert_equal 'Bearer token', result[ :authorization ]
        assert_nil result[ :api_key ]
      end

      def test_array_with_as
        builder = build_schema do
          tags_list String, as: :tags, array: true
        end

        result = builder.build { tags_list [ 'tag1', 'tag2' ] }
        assert_equal [ 'tag1', 'tag2' ], result[ :tags ]
        assert_nil result[ :tags_list ]
      end

      def test_multiple_params_map_to_same_key
        builder = build_schema do
          username String, as: :user
          user_name String, as: :user
        end

        result = builder.build { username 'testuser' }
        assert_equal 'testuser', result[ :user ]

        result = builder.build { user_name 'anotheruser' }
        assert_equal 'anotheruser', result[ :user ]
      end

      def test_object_with_as
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
        end

        assert_equal 1, result[ :messages ].length
        assert_nil result[ :message ]
      end
    end

  end
end
