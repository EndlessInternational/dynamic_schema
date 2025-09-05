require 'spec_helper'

RSpec.describe DynamicSchema::Struct do

  describe 'to_h method' do

    it 'converts struct with nested object fields to a hash' do
      klass = described_class.define do
        api_key String
        options do
          model String
        end
      end

      instance = klass.build
      instance.api_key = 'test-key'
      instance.options.model = 'test-model'

      expect( instance.to_h ).to eq( {
        api_key: 'test-key',
        options: { model: 'test-model' }
      } )
    end

    it 'handles empty structs' do
      empty_class = described_class.define do
        # no fields
      end

      instance = empty_class.build
      expect( instance.to_h ).to eq( {} )
    end

    it 'handles nested arrays of objects' do
      klass = described_class.define do
        messages array: true do
          role    String
          content String
        end
      end

      instance = klass.build
      instance.messages = [
        { role: 'user',      content: 'Hello!' },
        { role: 'assistant', content: 'Hi there!' }
      ]

      expect( instance.to_h ).to eq( {
        messages: [
          { role: 'user', content: 'Hello!' },
          { role: 'assistant', content: 'Hi there!' }
        ]
      } )
    end

    it 'omits empty nested objects and arrays from the hash' do
      klass = described_class.define do
        meta do
          tag String
        end
        items array: true do
          value Integer
        end
      end

      instance = klass.build
      # meta has no values and items is an empty array by default
      expect( instance.meta.to_h ).to eq( {} )
      expect( instance.to_h ).to eq( {} )

      # When providing explicit empties, they are also omitted
      instance.meta = {}
      instance.items = []
      expect( instance.to_h ).to eq( {} )
    end

    it 'includes custom class values as-is (and arrays of them)' do
      class Customer
        attr_accessor :name
      end

      klass = described_class.define do
        customer Customer
        customers Customer, array: true
      end

      instance = klass.build
      instance.customer = Customer.new
      instance.customer.name = 'Kristoph'
      instance.customers = [ Customer.new, Customer.new ]
      instance.customers[ 0 ].name = 'A'
      instance.customers[ 1 ].name = 'B'

      result = instance.to_h
      expect( result[ :customer ] ).to be_a( Customer )
      expect( result[ :customer ].name ).to eq( 'Kristoph' )
      expect( result[ :customers ] ).to be_a( Array )
      expect( result[ :customers ].map( &:class ).uniq ).to eq( [ Customer ] )
      expect( result[ :customers ].map( &:name ) ).to eq( [ 'A', 'B' ] )
    end

    it 'applies alias keys via :as in the output' do
      klass = described_class.define do
        title String, as: :original_title
        people array: true, as: :person do
          full_name String
        end
      end

      instance = klass.build
      instance.title = 'Quarterly Report'
      instance.people = [ { full_name: 'Sam Lee' } ]

      expect( instance.to_h ).to eq( {
        original_title: 'Quarterly Report',
        person: [ { full_name: 'Sam Lee' } ]
      } )
    end

  end

end
