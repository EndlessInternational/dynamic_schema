require 'spec_helper'

RSpec.describe DynamicSchema::Builder do
  describe 'schema with recursive parameters' do
 
    RECURSIVE_PARAMETERS = proc {
      value
      recursive_parameters &RECURSIVE_PARAMETERS 
    }

    it 'constructs a builder without a stack overflow' do 
      builder = described_class.new.define &RECURSIVE_PARAMETERS
      expect( builder ).to be_a( described_class )
    end

    it 'constructs a builder which allows mutliple levels of assignment' do 
      builder = described_class.new.define &RECURSIVE_PARAMETERS
      result = builder.build! do 
        value :one 
        recursive_parameters do 
          value :two 
          recursive_parameters do 
            value :three 
            recursive_parameters do 
              value :four
            end
          end
        end
      end

      expect( result[ :value ] ).to eq( :one )
      expect( result[ :recursive_parameters][ :value ] ).to eq( :two )
      expect( result[ :recursive_parameters ][ :recursive_parameters][ :value ] ).to eq( :three ) 
      expect( 
        result[ :recursive_parameters ][ :recursive_parameters][ :recursive_parameters ][ :value ] 
      ).to eq( :four ) 
    end

  end
end

