require 'spec_helper.rb'

RSpec.describe DynamicSchema::Receiver do

  describe ':as option' do

    it 'uses the :as option to rename keys' do
      schema = {
        apiKey: { type: String, as: :api_key }
      }
      receiver = build_receiver( schema: schema )
      receiver.apiKey 'test-key'

      result = receiver.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :apiKey ] ).to be_nil
    end

    it 'applies the :as option within nested parameters' do
      schema = {
        settings: {
          type: Object,
          schema: {
            userName: { type: String, as: :user_name }
          }
        }
      }
      receiver = build_receiver( schema: schema )
      
      receiver.settings do
        userName 'testuser'
      end
      
      result = receiver.to_h
      expect( result[ :settings ][ :user_name ] ).to eq( 'testuser' )
      expect( result[ :settings ][ :userName ] ).to be_nil
    end

  end

end
