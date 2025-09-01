require 'spec_helper'

RSpec.describe DynamicSchema::Receiver::Object do

  describe 'respond_to? Method' do

    it 'responds to defined parameters' do
      schema = {
        api_key: { type: String }
      }
      receiver = build_receiver( schema: schema )

      expect( receiver.respond_to?( :api_key ) ).to be true
    end

    it 'does not respond to undefined parameters' do
      schema = {
        api_key: { type: String }
      }
      receiver = build_receiver( schema: schema )

      expect( receiver.respond_to?( :undefined_param ) ).to be false
    end

    it 'responds to methods defined in BasicObject' do
      schema = {}
      receiver = build_receiver( schema: schema )

      expect( receiver.respond_to?( :__send__ ) ).to be true
      expect( receiver.respond_to?( :__id__ ) ).to be true
    end

  end

end
