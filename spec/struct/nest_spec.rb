require 'spec_helper'

RSpec.describe DynamicSchema::Struct do

  context 'nested object accessors' do
    context 'where a struct contains an object-typed field' do
      it 'returns a nested struct instance with its own accessors' do
        company_class = described_class.define do
          employee do
            full_name String
            years_of_service Integer
          end
        end

        company = company_class.build( employee: { full_name: 'Sam Lee', years_of_service: 5 } )
        expect( company.employee ).to be_a( Object )
        expect( company.employee.respond_to?( :full_name ) ).to be true
        expect( company.employee.full_name ).to eq( 'Sam Lee' )
        expect( company.employee.years_of_service ).to eq( 5 )

        empty_company = company_class.build
        expect( empty_company.employee ).to be_a( Object )
        expect( empty_company.employee.to_h ).to eq( {} )
      end
    end

    context 'where a struct contains an array of object-typed fields' do
      it 'returns an array of nested struct instances' do
        order_class = described_class.define do
          items array: true do
            price Integer
          end
        end

        order = order_class.build( items: [ { price: 100 }, { price: 200 } ] )
        expect( order.items ).to be_a( Array )
        expect( order.items.map { | item | item.price } ).to eq( [ 100, 200 ] )

        empty_order = order_class.build
        expect( empty_order.items ).to eq( [] )
      end
    end
  end

  context 'nested writers and deep nesting' do

    context 'where a struct field references another struct class and is declared as an array' do
      it 'exposes nested accessors when building with a hash of values' do
        order_item_class = described_class.define do
          name     String
          quantity Integer
        end

        order_class = described_class.define do
          order_number String
          line_items order_item_class, array: true
        end

        order = order_class.new( {
          order_number: 'A-100',
          line_items: [ { name: 'Desk', quantity: 1 }, { name: 'Chair', quantity: 2 } ]
        } )

        expect( order.line_items[ 0 ].name ).to eq( 'Desk' )
        expect( order.line_items[ 1 ].quantity ).to eq( 2 )
      end
    end

    context 'where a nested object is assigned via writer with a hash' do
      it 'coerces the hash into a nested receiver and exposes accessors' do
        family_class = described_class.define do
          child do
            full_name String
            age  Integer
          end
        end

        family = family_class.build
        family.child = { full_name: 'Zoe Hart', age: 9 }

        expect( family.child.full_name ).to eq( 'Zoe Hart' )
        expect( family.child.age ).to eq( 9 )
        expect( family.to_h ).to include( child: { full_name: 'Zoe Hart', age: 9 } )
      end
    end

    context 'where an array of nested objects is assigned via writer' do
      it 'coerces each hash into a nested receiver' do
        shopping_list_class = described_class.define do
          entries array: true do
            quantity Integer
          end
        end

        shopping_list = shopping_list_class.build
        shopping_list.entries = [ { quantity: 3 }, { quantity: 4 } ]

        expect( shopping_list.entries.map { | item | item.quantity } ).to eq( [ 3, 4 ] )
        expect( shopping_list.to_h ).to include( entries: [ { quantity: 3 }, { quantity: 4 } ] )
      end
    end

    context 'where objects are nested multiple levels deep' do
      it 'supports deep nesting across multiple levels' do
        organization_class = described_class.define do
          department do
            team do
              name String
            end
          end
        end

        org = organization_class.build( department: { team: { name: 'Platform' } } )
        expect( org.department.team.name ).to eq( 'Platform' )

        org.department = { team: { name: 'Infrastructure' } }
        expect( org.department.team.name ).to eq( 'Infrastructure' )
      end
    end
  end

end
