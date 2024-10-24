require 'spec_helper'

RSpec.describe DynamicSchema::Receiver do
  describe 'type coersion' do

    it 'coerces string values to Integer when type is Integer' do
      schema = {
        count: { type: Integer }
      }
      receiver = build_receiver( schema: schema )

      receiver.count '42'

      result = receiver.to_h
      expect( result[ :count ] ).to eq( 42 )
      expect( result[ :count ] ).to be_a( Integer )
    end

    it 'coerces string values to Float when type is Float' do
      schema = {
        price: { type: Float }
      }
      receiver = build_receiver( schema: schema )

      receiver.price '19.99'

      result = receiver.to_h
      expect( result[ :price ] ).to eq( 19.99 )
      expect( result[ :price ] ).to be_a( Float )
    end

    it 'coerces string values to Date when type is Date' do
      schema = {
        start_date: { type: Date }
      }
      receiver = build_receiver( schema: schema )

      receiver.start_date '2023-01-01'

      result = receiver.to_h
      expect( result[ :start_date ] ).to eq( Date.new( 2023, 1, 1 ) )
      expect( result[ :start_date ] ).to be_a( Date )
    end

    it 'coerces string values to Time when type is Time' do
      schema = {
        start_time: { type: Time }
      }
      receiver = build_receiver( schema: schema )

      receiver.start_time '2023-01-01 12:34:56'

      result = receiver.to_h
      expect( result[ :start_time ] ).to eq( Time.parse( '2023-01-01 12:34:56' ) )
      expect( result[ :start_time ] ).to be_a( Time )
    end

    it 'coerces string values to URI when type is URI' do
      schema = {
        website: { type: URI }
      }
      receiver = build_receiver( schema: schema )

      receiver.website 'http://example.com'

      result = receiver.to_h
      expect( result[ :website ] ).to eq( URI.parse( 'http://example.com' ) )
      expect( result[ :website ] ).to be_a( URI )
    end

    it 'coerces values to TrueClass class when compatible value is given' do
      schema = {
        enabled: { type: [ TrueClass, FalseClass ] }
      }
      receiver = build_receiver( schema: schema )

      receiver.enabled 'yes'

      result = receiver.to_h
      expect( result[ :enabled ] ).to eq( true )

      receiver.enabled 'true'

      result = receiver.to_h
      expect( result[ :enabled ] ).to eq( true )
    end

    it 'coerces values to FalseClass when compatible value is given' do
      schema = {
        disabled: { type: [ TrueClass, FalseClass ] }
      }
      receiver = build_receiver( schema: schema )

      receiver.disabled 'no'

      result = receiver.to_h
      expect( result[ :disabled ] ).to eq( false )

      receiver.disabled 'false'

      result = receiver.to_h
      expect( result[ :disabled ] ).to eq( false )
    end

    it 'coerces values to Symbol when compatible value is given' do 
      schema = {
        strategy: { type: Symbol }
      }
      receiver = build_receiver( schema: schema )

      receiver.strategy 'fight'

      result = receiver.to_h
      expect( result[ :strategy ] ).to be_a( Symbol )
      expect( result[ :strategy ] ).to eq :fight 

      receiver.strategy 'flight'

      result = receiver.to_h
      expect( result[ :strategy ] ).to be_a( Symbol )
      expect( result[ :strategy ] ).to eq :flight 
    end

    it 'allows custom converters to be added' do
      
      class UpcaseString < String
        def initialize( string )
          super( string.upcase )
        end
      end

      builder = DynamicSchema::Builder.new
      builder.convertor( UpcaseString ) { | v | UpcaseString.new( v ) }
      builder.define {
        name UpcaseString
      }

      result = builder.build! do
        name 'john doe'
      end 

      expect( result[ :name ] ).to be_a( UpcaseString )
      expect( result[ :name ].to_s ).to eq( 'JOHN DOE' )
    end

    it 'coerces array parameters' do
      schema = {
        numbers: { type: Integer, array: true }
      }
      receiver = build_receiver( schema: schema )

      receiver.numbers [ '1', '2', '3' ]

      result = receiver.to_h
      expect( result[ :numbers ] ).to eq( [ 1, 2, 3 ] )
    end

    it 'coerces nested receivers' do
      schema = {
        user: {
          type: Object,
          schema: {
            age: { type: Integer }
          }
        }
      }
      receiver = build_receiver( schema: schema )

      receiver.user do
        age '30'
      end

      result = receiver.to_h
      expect( result[ :user ][ :age ] ).to eq( 30 )
      expect( result[ :user ][ :age ] ).to be_a( Integer )
    end

    it 'coerces using multiple types' do
      builder = DynamicSchema::Builder.new
      builder.define {
        value [ Integer, String ]
      }

      result = builder.build! do
        value '42'
      end

      expect( result[ :value ] ).to eq( '42' )
  
      result = builder.build do 
        value 'not a number'
      end

      expect( result[ :value ] ).to eq( 'not a number' )
    end

    it 'supports coercion with multiple possible types' do
      schema = {
        flexible_param: { type: [ Integer, String ] }
      }
      receiver = build_receiver( schema: schema )

      receiver.flexible_param '123'
      
      result = receiver.to_h
      expect( result[ :flexible_param ] ).to be_a( String )
      expect( result[ :flexible_param ] ).to eq( '123' )

      receiver.flexible_param 123
      
      result = receiver.to_h
      expect( result[ :flexible_param ] ).to be_a( Integer )
      expect( result[ :flexible_param ] ).to eq( 123 )
    end

  end
end
