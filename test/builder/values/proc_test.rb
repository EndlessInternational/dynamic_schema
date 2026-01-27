require_relative '../../test_helper'

module Builder
  module Values

    # tests for Proc type values
    class ProcTest < Minitest::Test
      include TestHelper

      def test_proc_type_accepts_lambda
        builder = build_schema do
          callback Proc
        end

        my_proc = -> { 'hello' }
        result = builder.build { callback my_proc }

        assert_instance_of Proc, result[ :callback ]
        assert_equal 'hello', result[ :callback ].call
      end

      def test_proc_type_accepts_proc
        builder = build_schema do
          callback Proc
        end

        my_proc = proc { 'hello' }
        result = builder.build { callback my_proc }

        assert_instance_of Proc, result[ :callback ]
        assert_equal 'hello', result[ :callback ].call
      end

      def test_proc_type_block_becomes_value
        # special behavior: when type is Proc, a block is stored as the value
        builder = build_schema do
          callback Proc
        end

        result = builder.build do
          callback { 'from block' }
        end

        assert_instance_of Proc, result[ :callback ]
        assert_equal 'from block', result[ :callback ].call
      end

      def test_proc_with_arguments
        builder = build_schema do
          transformer Proc
        end

        result = builder.build do
          transformer { | x | x * 2 }
        end

        assert_equal 10, result[ :transformer ].call( 5 )
      end

      def test_proc_in_array
        builder = build_schema do
          hooks Proc, array: true
        end

        result = builder.build do
          hooks -> { 'first' }
          hooks -> { 'second' }
        end

        assert_equal 2, result[ :hooks ].length
        assert_equal 'first', result[ :hooks ][ 0 ].call
        assert_equal 'second', result[ :hooks ][ 1 ].call
      end

    end

  end
end
