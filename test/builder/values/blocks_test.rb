require_relative '../../test_helper'

module Builder
  module Values

    # tests for using blocks to set attributes on custom class instances
    module Blocks

      class BasicTest < Minitest::Test
        include TestHelper

        def setup
          @customer_class = Class.new do
            attr_accessor :name, :email
          end
        end

        def test_auto_instantiates_and_applies_block
          customer_class = @customer_class

          builder = build_schema do
            customer customer_class
          end

          result = builder.build! do
            customer do
              name 'Alice'
              email 'alice@example.com'
            end
          end

          assert_instance_of customer_class, result[ :customer ]
          assert_equal 'Alice', result[ :customer ].name
          assert_equal 'alice@example.com', result[ :customer ].email
        end

        def test_uses_provided_instance_with_block
          customer_class = @customer_class

          builder = build_schema do
            customer customer_class
          end

          instance = customer_class.new
          instance.name = 'Bob'

          result = builder.build! do
            customer instance do
              email 'bob@example.com'
            end
          end

          assert_same instance, result[ :customer ]
          assert_equal 'Bob', result[ :customer ].name
          assert_equal 'bob@example.com', result[ :customer ].email
        end

        def test_provided_instance_without_block
          customer_class = @customer_class

          builder = build_schema do
            customer customer_class
          end

          instance = customer_class.new
          instance.name = 'Carol'

          result = builder.build! do
            customer instance
          end

          assert_same instance, result[ :customer ]
          assert_equal 'Carol', result[ :customer ].name
        end
      end

      class ArrayTest < Minitest::Test
        include TestHelper

        def setup
          @item_class = Class.new do
            attr_accessor :name, :price
          end
        end

        def test_array_auto_instantiates_with_blocks
          item_class = @item_class

          builder = build_schema do
            item item_class, array: true
          end

          result = builder.build! do
            item do
              name 'Widget'
              price 100
            end
            item do
              name 'Gadget'
              price 200
            end
          end

          assert_equal 2, result[ :item ].length
          assert_instance_of item_class, result[ :item ][ 0 ]
          assert_equal 'Widget', result[ :item ][ 0 ].name
          assert_equal 100, result[ :item ][ 0 ].price
          assert_instance_of item_class, result[ :item ][ 1 ]
          assert_equal 'Gadget', result[ :item ][ 1 ].name
          assert_equal 200, result[ :item ][ 1 ].price
        end

        def test_array_with_provided_instances
          item_class = @item_class

          builder = build_schema do
            item item_class, array: true
          end

          item1 = item_class.new
          item1.name = 'First'

          item2 = item_class.new
          item2.name = 'Second'

          result = builder.build! do
            item [ item1, item2 ]
          end

          assert_equal 2, result[ :item ].length
          assert_same item1, result[ :item ][ 0 ]
          assert_same item2, result[ :item ][ 1 ]
        end

        def test_array_with_provided_instances_and_block
          item_class = @item_class

          builder = build_schema do
            item item_class, array: true
          end

          item1 = item_class.new
          item1.name = 'First'

          item2 = item_class.new
          item2.name = 'Second'

          result = builder.build! do
            item [ item1, item2 ] do
              price 50
            end
          end

          assert_equal 2, result[ :item ].length
          assert_equal 'First', result[ :item ][ 0 ].name
          assert_equal 50, result[ :item ][ 0 ].price
          assert_equal 'Second', result[ :item ][ 1 ].name
          assert_equal 50, result[ :item ][ 1 ].price
        end

        def test_array_with_nil_and_block
          item_class = @item_class

          builder = build_schema do
            item item_class, array: true
          end

          result = builder.build! do
            item nil do
              name 'Created'
              price 99
            end
          end

          assert_equal 1, result[ :item ].length
          assert_instance_of item_class, result[ :item ][ 0 ]
          assert_equal 'Created', result[ :item ][ 0 ].name
          assert_equal 99, result[ :item ][ 0 ].price
        end

        def test_array_with_as_option
          item_class = @item_class

          builder = build_schema do
            item item_class, array: true, as: :items
          end

          result = builder.build! do
            item do
              name 'Mapped'
            end
          end

          assert_equal 1, result[ :items ].length
          assert_nil result[ :item ]
          assert_equal 'Mapped', result[ :items ][ 0 ].name
        end
      end

      class SingleItemTypeArrayTest < Minitest::Test
        include TestHelper

        def test_single_type_in_array_instantiates
          item_class = Class.new do
            attr_accessor :name
          end

          builder = build_schema do
            item [ item_class ]
          end

          result = builder.build! do
            item do
              name 'Single Type'
            end
          end

          assert_instance_of item_class, result[ :item ]
          assert_equal 'Single Type', result[ :item ].name
        end
      end

      class ErrorCasesTest < Minitest::Test
        include TestHelper

        def test_raises_for_class_without_accessor
          klass = Class.new
          # no attr_accessor

          builder = build_schema do
            thing klass
          end

          assert_raises NoMethodError do
            builder.build! do
              thing do
                name 'test'
              end
            end
          end
        end

        def test_raises_for_class_requiring_arguments
          klass = Class.new do
            attr_accessor :name
            def initialize( required_arg: )
              @name = nil
            end
          end

          builder = build_schema do
            thing klass
          end

          assert_raises TypeError do
            builder.build! do
              thing do
                name 'test'
              end
            end
          end
        end

        def test_raises_for_multiple_types_with_block
          klass = Class.new do
            attr_accessor :name
          end

          builder = build_schema do
            thing [ klass, String ]
          end

          assert_raises TypeError do
            builder.build! do
              thing do
                name 'test'
              end
            end
          end
        end

        def test_raises_for_scalar_type_with_block
          builder = build_schema do
            value String
          end

          assert_raises NoMethodError do
            builder.build! do
              value 'test' do
                name 'invalid'
              end
            end
          end
        end

        def test_raises_for_wrong_instance_type
          klass = Class.new do
            attr_accessor :name
          end

          builder = build_schema do
            thing klass
          end

          assert_raises NoMethodError do
            builder.build! do
              thing 'not an instance' do
                name 'test'
              end
            end
          end
        end

        def test_raises_for_setter_without_value
          klass = Class.new do
            attr_accessor :name
          end

          builder = build_schema do
            thing klass
          end

          assert_raises ArgumentError do
            builder.build! do
              thing klass.new do
                name
              end
            end
          end
        end

        def test_raises_for_array_with_hash_entries_and_block
          klass = Class.new do
            attr_accessor :name
          end

          builder = build_schema do
            thing klass, array: true
          end

          assert_raises NoMethodError do
            builder.build! do
              thing [ { name: 'hash' } ] do
                name 'block'
              end
            end
          end
        end
      end

      class ConstructionEdgeCasesTest < Minitest::Test
        include TestHelper

        def test_object_provided_is_not_reconstructed
          # ensure when object is provided, it's used directly not reconstructed
          call_count = 0
          klass = Class.new do
            attr_accessor :name
            define_method( :initialize ) do
              call_count += 1
            end
          end

          builder = build_schema do
            thing klass
          end

          instance = klass.new
          initial_count = call_count

          result = builder.build! do
            thing instance do
              name 'test'
            end
          end

          # should not have called initialize again
          assert_equal initial_count, call_count
          assert_same instance, result[ :thing ]
        end

        def test_nil_value_triggers_construction
          call_count = 0
          klass = Class.new do
            attr_accessor :name
            define_method( :initialize ) do
              call_count += 1
            end
          end

          builder = build_schema do
            thing klass
          end

          initial_count = call_count

          result = builder.build! do
            thing nil do
              name 'constructed'
            end
          end

          # should have called initialize
          assert_equal initial_count + 1, call_count
          assert_equal 'constructed', result[ :thing ].name
        end

        def test_block_only_triggers_construction
          call_count = 0
          klass = Class.new do
            attr_accessor :name
            define_method( :initialize ) do
              call_count += 1
            end
          end

          builder = build_schema do
            thing klass
          end

          initial_count = call_count

          result = builder.build! do
            thing do
              name 'constructed'
            end
          end

          # should have called initialize once
          assert_equal initial_count + 1, call_count
          assert_equal 'constructed', result[ :thing ].name
        end

        def test_provided_object_of_correct_type_used_directly
          klass = Class.new do
            attr_accessor :name, :original
            def initialize
              @original = true
            end
          end

          builder = build_schema do
            thing klass
          end

          instance = klass.new
          instance.name = 'original'

          result = builder.build! do
            thing instance
          end

          assert_same instance, result[ :thing ]
          assert_equal true, result[ :thing ].original
          assert_equal 'original', result[ :thing ].name
        end
      end

    end

  end
end
