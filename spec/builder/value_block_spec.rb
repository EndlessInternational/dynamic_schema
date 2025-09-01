require 'spec_helper'

RSpec.describe DynamicSchema::Builder do
  describe 'value blocks with explicit instances' do
    it 'applies block via writer to a single instance' do
      class ValueBlockCustomer
        attr_accessor :value
      end

      builder = described_class.new.define do
        something ValueBlockCustomer
      end

      instance = ValueBlockCustomer.new
      result = builder.build! do
        something instance do
          value 123
        end
      end

      expect( result[ :something ] ).to equal( instance )
      expect( result[ :something ].value ).to eq( 123 )
    end

    it 'raises ArgumentError when a block is given without a value instance' do
      class ValueBlockNeedsInstance
        attr_accessor :value
      end

      builder = described_class.new.define do
        something ValueBlockNeedsInstance
      end

      expect do
        builder.build! do
          something do
            value 123
          end
        end
      end.to raise_error( ArgumentError, /value instance is required/ )
    end

    it 'raises NoMethodError when writer is missing' do
      class ValueBlockNoWriter
        # no writer defined
      end

      builder = described_class.new.define do
        something ValueBlockNoWriter
      end

      instance = ValueBlockNoWriter.new

      expect do
        builder.build! do
          something instance do
            value 123
          end
        end
      end.to raise_error( NoMethodError, /cannot be assigned/ )
    end

    it 'raises ArgumentError when wrong arity is given' do
      class ValueBlockArity
        attr_accessor :value
      end

      builder = described_class.new.define do
        something ValueBlockArity
      end

      instance = ValueBlockArity.new

      expect do
        builder.build! do
          something instance do
            value 1, 2
          end
        end
      end.to raise_error( ArgumentError, /requires 1 argument/ )
    end

    it 'does not fall back to calling a reader/method; requires a writer' do
      class ValueBlockHasMethod
        def value( arg )
          @called_value_method = arg
        end
      end

      builder = described_class.new.define do
        something ValueBlockHasMethod
      end

      instance = ValueBlockHasMethod.new

      expect do
        builder.build! do
          something instance do
            value 123
          end
        end
      end.to raise_error( NoMethodError, /cannot be assigned/ )
    end

    it 'applies block to each element when an array of instances is provided' do
      class ValueBlockItem
        attr_accessor :value
      end

      builder = described_class.new.define do
        items ValueBlockItem, array: true
      end

      a = ValueBlockItem.new
      b = ValueBlockItem.new

      result = builder.build! do
        items [ a, b ] do
          value 'x'
        end
      end

      expect( result[ :items ] ).to be_a( Array )
      expect( result[ :items ].length ).to eq( 2 )
      expect( result[ :items ][ 0 ] ).to equal( a )
      expect( result[ :items ][ 1 ] ).to equal( b )
      expect( result[ :items ].map( &:value ) ).to eq( [ 'x', 'x' ] )
    end

    it 'handles an empty array without error when a block is given' do
      class ValueBlockItem2
        attr_accessor :value
      end

      builder = described_class.new.define do
        items ValueBlockItem2, array: true
      end

      result = builder.build! do
        items [] do
          value 'x'
        end
      end

      expect( result[ :items ] ).to eq( [] )
    end
  end
end
