require_relative '../test_helper'

module StructTests
  module Nesting

    class NestedObjectTest < Minitest::Test

      def test_nested_object_returns_accessors
        company_class = DynamicSchema::Struct.define do
          employee do
            full_name String
            years_of_service Integer
          end
        end

        company = company_class.build( employee: { full_name: 'Sam Lee', years_of_service: 5 } )

        assert company.employee.respond_to?( :full_name )
        assert_equal 'Sam Lee', company.employee.full_name
        assert_equal 5, company.employee.years_of_service
      end

      def test_empty_nested_object
        company_class = DynamicSchema::Struct.define do
          employee do
            full_name String
          end
        end

        empty_company = company_class.build
        assert_equal( {}, empty_company.employee.to_h )
      end

      def test_nested_object_writer_with_hash
        family_class = DynamicSchema::Struct.define do
          child do
            full_name String
            age Integer
          end
        end

        family = family_class.build
        family.child = { full_name: 'Zoe Hart', age: 9 }

        assert_equal 'Zoe Hart', family.child.full_name
        assert_equal 9, family.child.age
        assert_includes family.to_h, :child
      end
    end

    class ArrayOfObjectsTest < Minitest::Test

      def test_array_of_nested_objects
        order_class = DynamicSchema::Struct.define do
          items array: true do
            price Integer
          end
        end

        order = order_class.build( items: [ { price: 100 }, { price: 200 } ] )

        assert_instance_of Array, order.items
        assert_equal [ 100, 200 ], order.items.map { | item | item.price }
      end

      def test_empty_array_of_objects
        order_class = DynamicSchema::Struct.define do
          items array: true do
            price Integer
          end
        end

        empty_order = order_class.build
        assert_equal [], empty_order.items
      end

      def test_array_writer_coerces_hashes
        shopping_list_class = DynamicSchema::Struct.define do
          entries array: true do
            quantity Integer
          end
        end

        shopping_list = shopping_list_class.build
        shopping_list.entries = [ { quantity: 3 }, { quantity: 4 } ]

        assert_equal [ 3, 4 ], shopping_list.entries.map { | item | item.quantity }
      end
    end

    class DeepNestingTest < Minitest::Test

      def test_multiple_levels_deep
        organization_class = DynamicSchema::Struct.define do
          department do
            team do
              name String
            end
          end
        end

        org = organization_class.build( department: { team: { name: 'Platform' } } )
        assert_equal 'Platform', org.department.team.name

        org.department = { team: { name: 'Infrastructure' } }
        assert_equal 'Infrastructure', org.department.team.name
      end
    end

    class ReferencedStructTest < Minitest::Test

      def test_struct_as_field_type
        order_item_class = DynamicSchema::Struct.define do
          name String
          quantity Integer
        end

        order_class = DynamicSchema::Struct.define do
          order_number String
          line_items order_item_class, array: true
        end

        order = order_class.new( {
          order_number: 'A-100',
          line_items: [ { name: 'Desk', quantity: 1 }, { name: 'Chair', quantity: 2 } ]
        } )

        assert_equal 'Desk', order.line_items[ 0 ].name
        assert_equal 2, order.line_items[ 1 ].quantity
      end
    end

  end

end
