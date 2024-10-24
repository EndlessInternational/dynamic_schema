require 'spec_helper'

RSpec.describe DynamicSchema::Receiver do

  describe ':array option' do

    it 'handles array parameters correctly' do
      schema = {
        tags: { type: String, array: true }
      }

      receiver = build_receiver( schema: schema )
      receiver.tags [ 'tag1', 'tag2' ]

      result = receiver.to_h
      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
    end

    it 'appends to array parameters when called multiple times' do
      schema = {
        tags: { type: String, array: true }
      }

      receiver = build_receiver( schema: schema )
      receiver.tags [ 'tag1' ]
      receiver.tags [ 'tag2', 'tag3' ]

      result = receiver.to_h
      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2', 'tag3' ] )
    end

  end

end
