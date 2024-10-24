require 'spec_helper.rb'

RSpec.describe DynamicSchema::Receiver do

  describe 'Class Methods and Attributes' do

    it 'returns correct class' do
      schema = {}
      receiver = build_receiver( schema: schema )

      expect( receiver.class ).to eq( DynamicSchema::Receiver )
    end

    it 'checks instance of correctly' do
      schema = {}
      receiver = build_receiver( schema: schema )

      expect( receiver.is_a?( DynamicSchema::Receiver ) ).to be true
    end

  end

end
