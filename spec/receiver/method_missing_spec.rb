require 'spec_helper'

RSpec.describe DynamicSchema::Receiver do

  let( :schema ) do
    {
      api_key:  { type: String },
      options:  {
        type: Object,
        schema: {
          model: { type: String }
        }
      }
    }
  end

  describe 'method Missing and dynamic methods' do

    it 'allows setting and getting parameters using method calls' do
      receiver = build_receiver( schema: schema )

      receiver.api_key 'test-key'
      result = receiver.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
    end

    it 'supports nested parameters using method calls' do
      receiver = build_receiver( schema: schema )

      receiver.options do
        model 'test-model'
      end

      result = receiver.to_h
      expect( result[ :options ][ :model ] ).to eq( 'test-model' )
    end

    it 'raises NoMethodError for undefined methods' do
      receiver = build_receiver( schema: schema )

      expect {
        receiver.undefined_method
      }.to raise_error( NoMethodError )
    end

    it 'responds to defined methods' do
      receiver = build_receiver( schema: schema )

      expect( receiver.respond_to?( :api_key ) ).to be true
      expect( receiver.respond_to?( :options ) ).to be true
      expect( receiver.respond_to?( :undefined_method ) ).to be false
    end

  end

end
