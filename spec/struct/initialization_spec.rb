require 'spec_helper'

RSpec.describe DynamicSchema::Struct do

  context 'initialization and building' do

    context 'where a struct defines multiple attribute accessors' do
      context 'where values are provided to build and updated via writers' do
        it 'exposes readers and writers and validates when using build!' do
          product_class = described_class.define do
            name String
            quantity Integer
          end

          product = product_class.build( name: 'Desk', quantity: 1 )
          expect( product.name ).to eq( 'Desk' )
          expect( product.quantity ).to eq( 1 )

          product.name = 'Chair'
          product.quantity = 2
          expect( product.to_h ).to include( name: 'Chair', quantity: 2 )

          expect {
            product_class.build!( name: 'Valid', quantity: 'not-an-integer' )
          }.to raise_error( DynamicSchema::IncompatibleTypeError )

          expect {
            product_class.build!( name: 'Valid', quantity: 99 )
          }.not_to raise_error
        end
      end
    end

    context 'where a block is passed to build' do
      it 'yields the instance so that setters can be used' do
        customer_class = described_class.define do
          full_name String
        end

        customer = customer_class.build do | instance |
          instance.full_name = 'Carol Johnson'
        end

        expect( customer.full_name ).to eq( 'Carol Johnson' )
        expect( customer.to_h ).to include( full_name: 'Carol Johnson' )
      end
    end
  end

  context '.new with Proc' do
    context 'where a Proc is provided as the schema' do
      it 'compiles the schema and creates accessors' do
        person_class = described_class.new( proc { first_name String } )
        person = person_class.build( first_name: 'Alice' )
        expect( person.first_name ).to eq( 'Alice' )
        person.first_name = 'Bob'
        expect( person.to_h ).to include( first_name: 'Bob' )
      end
    end
  end

  context 'alias via :as mapping' do
    context 'where an attribute is defined with an alias' do
      it 'exposes only the alias and maps the value accordingly' do
        document_class = described_class.define do
          original_title String, as: :title
        end

        doc = document_class.build( title: 'Quarterly Report' )
        expect( doc.title ).to eq( 'Quarterly Report' )
        expect( doc.respond_to?( :original_title ) ).to be false

        doc.title = 'Annual Report'
        expect( doc.title ).to eq( 'Annual Report' )
        expect( doc.to_h ).to include( title: 'Annual Report' )
      end
    end
  end

  context '.new with Builder and compiled Hash' do
    context 'where a Builder is given' do
      it 'uses the Builder compiled schema' do
        builder = DynamicSchema.define do
          category String
        end
        category_class = described_class.new( builder )
        instance = category_class.build( category: 'Furniture' )
        expect( instance.category ).to eq( 'Furniture' )
      end
    end

    context 'where a compiled Hash schema is given' do
      it 'creates a struct that reads and writes those attributes' do
        compiled = { title: { type: String } }
        book_class = described_class.new( compiled )
        book = book_class.build( title: 'Dune' )
        expect( book.title ).to eq( 'Dune' )
      end
    end
  end

  context 'array non-object fields' do
    context 'where a field is an array of scalar values' do
      it 'returns raw arrays and supports assignment via writer' do
        inventory_class = described_class.define do
          quantities Integer, array: true
        end

        inventory = inventory_class.build( quantities: [ 1, 2, 3 ] )
        expect( inventory.quantities ).to eq( [ 1, 2, 3 ] )

        inventory.quantities = [ 4, 5 ]
        expect( inventory.to_h ).to include( quantities: [ 4, 5 ] )
      end
    end
  end

end
