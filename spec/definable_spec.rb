require 'spec_helper'

RSpec.describe DynamicSchema::Definable do

  class A
    include DynamicSchema::Definable

    schema do
      value_a 
    end
  end

  class B < A
    schema do
      value_b 
    end
  end

  class C < B
    schema do
      value_c 
    end
  end

  class D < A 
    schema do 
      value_a 
      value_d 
    end
  end

  context 'where a class calls the schema method' do 
    it 'defines a buildable schema' do 
      result = DynamicSchema::Builder.new.define( &A.schema ).build {
        value_a "A"
      }
      expect( result[ :value_a ] ).to eq( 'A' )
    end 
  end

  context 'where a class inherits from another class, both of which call the schema method' do 
    
    it 'defines a buildable schema' do 
      builder = DynamicSchema::Builder.new 
      builder.define( &B.schema )
      result = builder.build {
        value_a 'A'
        value_b 'B'
      }
      expect( result[ :value_a ] ).to eq( 'A' )
      expect( result[ :value_b ] ).to eq( 'B' )

      builder = DynamicSchema::Builder.new 
      builder.define( &C.schema )
      result = builder.build {
        value_a 'A'
        value_b 'B'
        value_c 'C'
      }
      expect( result[ :value_a ] ).to eq( 'A' )
      expect( result[ :value_b ] ).to eq( 'B' )
      expect( result[ :value_c ] ).to eq( 'C' )
    end 

    context 'where an inheriting class replaces a definition of the superclass' do 
      it 'defines a buildable schema' do 
        builder = DynamicSchema::Builder.new 
        builder.define( &D.schema )
        result = builder.build {
          value_a 'A'
          value_d 'D'
        }
        expect( result[ :value_a ] ).to eq( 'A' )
        expect( result[ :value_d ] ).to eq( 'D' )
      end 
    end

  end 

end
