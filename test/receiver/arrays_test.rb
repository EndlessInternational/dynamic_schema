require_relative '../test_helper'

module Receiver
  module Arrays

    class ValueArrayTest < Minitest::Test
      include TestHelper

      def test_wraps_single_value_in_array
        schema = { tags: { type: String, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.tags 'one'

        result = receiver.to_h
        assert_equal [ 'one' ], result[ :tags ]
      end

      def test_accepts_array_value
        schema = { tags: { type: String, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.tags [ 'one', 'two', 'three' ]

        result = receiver.to_h
        assert_equal [ 'one', 'two', 'three' ], result[ :tags ]
      end

      def test_appends_on_multiple_calls
        schema = { tags: { type: String, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.tags 'one'
        receiver.tags 'two'
        receiver.tags 'three'

        result = receiver.to_h
        assert_equal [ 'one', 'two', 'three' ], result[ :tags ]
      end

      def test_appends_arrays_on_multiple_calls
        schema = { tags: { type: String, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.tags [ 'one', 'two' ]
        receiver.tags [ 'three', 'four' ]

        result = receiver.to_h
        assert_equal [ 'one', 'two', 'three', 'four' ], result[ :tags ]
      end
    end

    class ObjectArrayTest < Minitest::Test
      include TestHelper

      def test_single_object_in_array
        schema = {
          items: {
            type: Object,
            array: true,
            schema: {
              name: { type: String }
            }
          }
        }
        receiver = build_receiver( schema: schema )

        receiver.items { name 'one' }

        result = receiver.to_h
        assert_equal 1, result[ :items ].length
        assert_equal 'one', result[ :items ][ 0 ][ :name ]
      end

      def test_multiple_objects_in_array
        schema = {
          items: {
            type: Object,
            array: true,
            schema: {
              name: { type: String }
            }
          }
        }
        receiver = build_receiver( schema: schema )

        receiver.items { name 'one' }
        receiver.items { name 'two' }
        receiver.items { name 'three' }

        result = receiver.to_h
        assert_equal 3, result[ :items ].length
        assert_equal 'one', result[ :items ][ 0 ][ :name ]
        assert_equal 'two', result[ :items ][ 1 ][ :name ]
        assert_equal 'three', result[ :items ][ 2 ][ :name ]
      end

      def test_object_array_with_hash_input
        schema = {
          items: {
            type: Object,
            array: true,
            schema: {
              name: { type: String },
              value: { type: Integer }
            }
          }
        }
        receiver = build_receiver( schema: schema )

        receiver.items( { name: 'one', value: 1 } )
        receiver.items( { name: 'two', value: 2 } )

        result = receiver.to_h
        assert_equal 2, result[ :items ].length
        assert_equal 'one', result[ :items ][ 0 ][ :name ]
        assert_equal 1, result[ :items ][ 0 ][ :value ]
        assert_equal 'two', result[ :items ][ 1 ][ :name ]
        assert_equal 2, result[ :items ][ 1 ][ :value ]
      end
    end

    class TypedArrayTest < Minitest::Test
      include TestHelper

      def test_integer_array
        schema = { numbers: { type: Integer, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.numbers [ 1, 2, 3 ]

        result = receiver.to_h
        assert_equal [ 1, 2, 3 ], result[ :numbers ]
      end

      def test_float_array
        schema = { values: { type: Float, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.values [ 1.1, 2.2, 3.3 ]

        result = receiver.to_h
        assert_equal [ 1.1, 2.2, 3.3 ], result[ :values ]
      end

      def test_symbol_array
        schema = { symbols: { type: Symbol, array: true } }
        receiver = build_receiver( schema: schema )

        receiver.symbols [ :one, :two, :three ]

        result = receiver.to_h
        assert_equal [ :one, :two, :three ], result[ :symbols ]
      end

      def test_boolean_array
        schema = { flags: { type: [ TrueClass, FalseClass ], array: true } }
        receiver = build_receiver( schema: schema )

        receiver.flags [ true, false, true ]

        result = receiver.to_h
        assert_equal [ true, false, true ], result[ :flags ]
      end
    end

    class ArrayDefaultTest < Minitest::Test
      include TestHelper

      def test_array_with_default
        schema = {
          tags: { type: String, array: true, default: [ 'default1', 'default2' ] }
        }
        receiver = build_receiver( schema: schema )

        result = receiver.to_h
        assert_equal [ 'default1', 'default2' ], result[ :tags ]
      end

      def test_array_default_replaced_on_set
        schema = {
          tags: { type: String, array: true, default: [ 'default1', 'default2' ] }
        }
        receiver = build_receiver( schema: schema )

        receiver.tags [ 'new1', 'new2' ]

        result = receiver.to_h
        assert_equal [ 'new1', 'new2' ], result[ :tags ]
      end

      def test_array_default_replaced_not_appended
        schema = {
          tags: { type: String, array: true, default: [ 'default1' ] }
        }
        receiver = build_receiver( schema: schema )

        receiver.tags 'new'

        result = receiver.to_h
        # should replace, not append to default
        assert_equal [ 'new' ], result[ :tags ]
      end
    end

    class ArrayWithAsOptionTest < Minitest::Test
      include TestHelper

      def test_array_with_as_option
        schema = {
          tag_list: { type: String, array: true, as: :tags }
        }
        receiver = build_receiver( schema: schema )

        receiver.tag_list [ 'one', 'two' ]

        result = receiver.to_h
        assert_equal [ 'one', 'two' ], result[ :tags ]
        assert_nil result[ :tag_list ]
      end
    end

    class UntypedArrayTest < Minitest::Test
      include TestHelper

      def test_mixed_type_array
        schema = { items: { array: true } }
        receiver = build_receiver( schema: schema )

        receiver.items [ 1, 'two', 3.0, :four, true ]

        result = receiver.to_h
        assert_equal [ 1, 'two', 3.0, :four, true ], result[ :items ]
      end
    end

  end

end
