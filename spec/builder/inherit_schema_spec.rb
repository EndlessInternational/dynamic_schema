require 'spec_helper'

RSpec.describe DynamicSchema::Builder do

  describe 'schema reuse and inheritance' do

    it 'reuses a builder schema via inherit to create an equivalent builder' do
      base = DynamicSchema.define do
        greeting String
      end

      reused = DynamicSchema.define( inherit: base.schema )

      result = reused.build! do
        greeting 'hello'
      end

      expect( result[ :greeting ] ).to eq( 'hello' )
    end

    it 'reuses schema with additional definitions using inherit' do
      base = DynamicSchema.define do
        a String
      end

      derived = DynamicSchema.define( inherit: base.schema ) do
        b Integer
      end

      result = derived.build! do
        a 'alpha'
        b 42
      end

      expect( result[ :a ] ).to eq( 'alpha' )
      expect( result[ :b ] ).to eq( 42 )
    end

    it 'supports double inherit chaining' do
      base = DynamicSchema.define do
        a String
      end

      derived1 = DynamicSchema.define( inherit: base.schema ) do
        b Integer
      end

      derived2 = DynamicSchema.define( inherit: derived1.schema ) do
        c Float
      end

      result = derived2.build! do
        a 'alpha'
        b 7
        c 3.14
      end

      expect( result[ :a ] ).to eq( 'alpha' )
      expect( result[ :b ] ).to eq( 7 )
      expect( result[ :c ] ).to eq( 3.14 )
    end

  end

end
