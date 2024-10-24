require 'spec_helper'

RSpec.describe DynamicSchema do
  describe '.define' do

    it 'constructs a Builder instance' do
      builder = described_class.define do 
      end
      expect( builder ).to be_a( DynamicSchema::Builder )
    end 

  end
end

