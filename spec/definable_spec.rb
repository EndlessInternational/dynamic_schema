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

  context '.schema' do 
    context 'where a class calls the schema method' do 
      it 'defines a buildable schema' do 
        result = DynamicSchema.define( &A.schema ).build {
          value_a "A"
        }
        expect( result[ :value_a ] ).to eq( 'A' )
      end 
    end

    context 'where a class inherits from another class, both of which call the schema method' do 
      
      it 'defines a buildable schema' do 
        builder = DynamicSchema.define( &B.schema )
        result = builder.build {
          value_a 'A'
          value_b 'B'
        }
        expect( result[ :value_a ] ).to eq( 'A' )
        expect( result[ :value_b ] ).to eq( 'B' )

        builder = DynamicSchema.define( &C.schema )
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
          builder = DynamicSchema.define( &D.schema )
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

  context '.builder' do 
    context 'where a class calls the schema method' do 
      it 'the builder method may be used to build the schema' do 
        result = A.builder.build { value_a "A" }
        expect{ A.builder.build { value_b "B" } }.to raise_error( NoMethodError )
        expect( result[ :value_a ] ).to eq( 'A' )
      end 
    end

    context 'where a class inherits from another class, both of which call the schema method' do    
      it 'the builder method may be used to build the schema' do 
        expect{ B.builder.build { value_c "C" } }.to raise_error( NoMethodError )
        result = B.builder.build {
          value_a 'A'
          value_b 'B'
        }
        expect( result[ :value_a ] ).to eq( 'A' )
        expect( result[ :value_b ] ).to eq( 'B' )

        expect{ C.builder.build { value_d "D" } }.to raise_error( NoMethodError )
        result = C.builder.build {
          value_a 'A'
          value_b 'B'
          value_c 'C'
        }
        expect( result[ :value_a ] ).to eq( 'A' )
        expect( result[ :value_b ] ).to eq( 'B' )
        expect( result[ :value_c ] ).to eq( 'C' )
      end 

      context 'where an inheriting class replaces a definition of the superclass' do 
        it 'the builder method may be used to build the schema' do 
          expect{ D.builder.build { value_b "B" } }.to raise_error( NoMethodError )
          expect{ D.builder.build { value_c "C" } }.to raise_error( NoMethodError )
          result = D.builder.build {
            value_a 'A'
            value_d 'D'
          }
          expect( result[ :value_a ] ).to eq( 'A' )
          expect( result[ :value_d ] ).to eq( 'D' )
        end 
      end

    end 
  end 

end
