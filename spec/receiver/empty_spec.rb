require 'spec_helper.rb'

RSpec.describe DynamicSchema::Receiver do

  describe 'empty? Method' do

    it 'returns true when context has no values' do
      schema = { api_key: { type: String } }
      receiver = build_receiver( schema: schema )
      expect( receiver.empty? ).to be true
    end

    it 'returns false when context has values' do
      schema = { api_key: { type: String } }
      receiver = build_receiver( schema: schema )
      receiver.api_key 'test-key'
      expect( receiver.empty? ).to be false
    end

  end

end
