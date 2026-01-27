require_relative '../../test_helper'

module Builder
  module MultipleTypes

    class EdgeCasesTest < Minitest::Test
      include TestHelper

      def test_nil_passes_through
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data nil
        end

        assert_nil result[ :data ]
      end

      def test_empty_hash_treated_as_object
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String, default: 'default'
          end
        end

        result = builder.build do
          data( {} )
        end

        assert_kind_of Hash, result[ :data ]
        assert_equal 'default', result[ :data ][ :value ]
      end

      def test_subclass_of_listed_type_is_valid
        parent_class = Class.new
        child_class = Class.new( parent_class )

        builder = build_schema do
          data [ Object, parent_class, TrueClass, FalseClass ] do
            value String
          end
        end

        child_instance = child_class.new
        result = builder.build do
          data child_instance
        end

        assert builder.valid?( result )
      end

      def test_module_as_type
        test_module = Module.new

        klass = Class.new do
          include test_module
        end

        builder = build_schema do
          data [ Object, test_module, TrueClass, FalseClass ] do
            value String
          end
        end

        instance = klass.new
        result = builder.build do
          data instance
        end

        assert builder.valid?( result )
      end

      def test_single_element_array_with_block_still_multi_type
        # even with single type, array + block = multi-type behavior
        builder = build_schema do
          data [ Object ] do
            value String
          end
        end

        result = builder.build do
          data do
            value 'nested'
          end
        end

        assert_equal 'nested', result[ :data ][ :value ]
      end

      def test_type_order_does_not_affect_hash_detection
        builder1 = build_schema do
          data [ TrueClass, Object, FalseClass ] do
            value String
          end
        end

        builder2 = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        result1 = builder1.build do
          data( { value: 'test' } )
        end

        result2 = builder2.build do
          data( { value: 'test' } )
        end

        assert_equal result1[ :data ][ :value ], result2[ :data ][ :value ]
      end

      def test_hash_like_object_not_treated_as_hash
        # object with [] method but not a Hash
        hash_like = Class.new do
          def []( key )
            :value
          end
          def key?( key )
            true
          end
        end

        builder = build_schema do
          data [ Object, hash_like, TrueClass, FalseClass ] do
            nested String
          end
        end

        instance = hash_like.new
        result = builder.build do
          data instance
        end

        # should pass through as scalar, not be treated as object
        assert_kind_of hash_like, result[ :data ]
      end

      def test_integer_zero_is_valid_scalar
        builder = build_schema do
          data [ Object, Integer, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data 0
        end

        assert_equal 0, result[ :data ]
        assert builder.valid?( result )
      end

      def test_empty_string_is_valid_scalar
        builder = build_schema do
          data [ Object, String, TrueClass, FalseClass ] do
            value Integer
          end
        end

        result = builder.build do
          data ''
        end

        assert_equal '', result[ :data ]
        assert builder.valid?( result )
      end

      def test_empty_array_as_scalar
        builder = build_schema do
          data [ Object, Array, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data []
        end

        assert_equal [], result[ :data ]
      end

      def test_multiple_calls_replace_value
        builder = build_schema do
          data [ Object, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data true
          data false
          data do
            value 'final'
          end
        end

        assert_equal 'final', result[ :data ][ :value ]
      end

      def test_coercion_string_to_integer_in_scalar_types
        builder = build_schema do
          data [ Object, Integer, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data '42'
        end

        # string should be coerced to integer
        assert_equal 42, result[ :data ]
      end

      def test_validates_with_numeric_types
        builder = build_schema do
          data [ Object, Integer, Float ] do
            value String
          end
        end

        result = builder.build do
          data 3.14
        end

        assert builder.valid?( result )
      end

      def test_invalid_with_wrong_numeric_type
        builder = build_schema do
          data [ Object, Integer ] do
            value String
          end
        end

        result = builder.build do
          data 'not a number'
        end

        refute builder.valid?( result )
      end

      def test_symbol_not_confused_with_hash
        builder = build_schema do
          data [ Object, Symbol, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data :my_symbol
        end

        assert_equal :my_symbol, result[ :data ]
      end

      def test_nested_hash_within_scalar_hash_type
        builder = build_schema do
          data [ Hash, TrueClass, FalseClass ] do
            value String
          end
        end

        result = builder.build do
          data( { value: 'content' } )
        end

        assert_equal 'content', result[ :data ][ :value ]
      end

    end

  end
end
