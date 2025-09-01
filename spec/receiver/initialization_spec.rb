require 'spec_helper'

RSpec.describe DynamicSchema::Receiver::Object do

  describe 'Initialization' do

    it 'initializes with given schema and values' do
      schema = {
        api_key:     { type: String },
        max_tokens:  { type: Integer, default: 100 }
      }
      values = { api_key: 'test-key' }
      receiver = build_receiver( values, schema: schema )

      result = receiver.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :max_tokens ] ).to eq( 100 )
    end

    it 'initializes with given schema and values when parameters are present' do
      schema = {
        api_key: { type: String },
        chat_options: {
          type: Object,
          schema: {
            max_tokens: { type: Integer, default: 100 }
          }
        }
      }
      values = { api_key: 'test-key', chat_options: { max_tokens: 1024 } }
      receiver = build_receiver( values, schema: schema )

      result = receiver.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :chat_options ][ :max_tokens ] ).to eq( 1024 )
    end

    it 'initializes with given values when aliases are present' do
      schema = {
        api_key:     { type: String, as: :apiKey },
        max_tokens:  { type: Integer, default: 100, as: :maxTokens }
      }
      values = { api_key: 'test-key' }
      receiver = build_receiver( values, schema: schema )

      result = receiver.to_h
      expect( result[ :apiKey ] ).to eq( 'test-key' )
      expect( result[ :maxTokens ] ).to eq( 100 )
    end

    it 'initializes with given values when parameters and aliases are present' do
      schema = {
        api_key: { type: String, as: :apiKey },
        chat_options: {
          type: Object,
          as: :chatOptions,
          schema: {
            max_tokens: { type: Integer, default: 100, as: :maxTokens }
          }
        }
      }
      values = { api_key: 'test-key', chat_options: { max_tokens: 1024 } }
      receiver = build_receiver( values, schema: schema )

      result = receiver.to_h
      expect( result[ :apiKey ] ).to eq( 'test-key' )
      expect( result[ :chatOptions ][ :maxTokens ] ).to eq( 1024 )
    end

    it 'sets default values when values are not provided' do
      schema = {
        timeout:  { type: Integer, default: 30 },
        retries:  { type: Integer, default: 3 }
      }
      receiver = build_receiver( schema: schema )

      result = receiver.to_h
      expect( result[ :timeout ] ).to eq( 30 )
      expect( result[ :retries ] ).to eq( 3 )
    end

    it 'created nested hashes for parameters types' do
      schema = {
        database: {
          type: Object,
          default: {},
          schema: {
            host: { type: String, default: 'localhost' },
            port: { type: Integer, default: 5432 }
          }
        }
      }
      receiver = build_receiver( schema: schema )

      result = receiver.to_h
      expect( result[ :database ] ).to be_a( Hash )
      expect( result[ :database ][ :host ] ).to eq( 'localhost' )
      expect( result[ :database ][ :port ] ).to eq( 5432 )
    end

  end

end
