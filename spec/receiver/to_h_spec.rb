require 'spec_helper'

RSpec.describe DynamicSchema::Receiver::Object do

  describe 'to_h method' do

    it 'converts receiver to a hash' do
      schema = {
        api_key:  { type: String },
        options:  {
          type: Object,
          schema: {
            model: { type: String }
          }
        }
      }
      receiver = build_receiver( schema: schema )

      receiver.api_key 'test-key'
      receiver.options do
        model 'test-model'
      end

      expected_hash = {
        api_key: 'test-key',
        options: {
          model: 'test-model'
        }
      }

      expect( receiver.to_h ).to eq( expected_hash )
    end

    it 'handles empty receivers' do
      schema = {}
      receiver = build_receiver( schema: schema )

      expect( receiver.to_h ).to eq( {} )
    end

    it 'handles nested receivers with arrays' do
      schema = {
        messages: {
          type: Object,
          array: true,
          schema: {
            role:    { type: String },
            content: { type: String }
          }
        }
      }
      receiver = build_receiver( schema: schema )

      receiver.messages do
        role 'user'
        content 'Hello!'
      end

      receiver.messages do
        role 'assistant'
        content 'Hi there!'
      end

      expected_hash = {
        messages: [
          { role: 'user', content: 'Hello!' },
          { role: 'assistant', content: 'Hi there!' }
        ]
      }

      expect( receiver.to_h ).to eq( expected_hash )
    end

  end

end
