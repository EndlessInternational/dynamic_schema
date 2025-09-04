require 'spec_helper'

RSpec.describe DynamicSchema::Struct do

  context 'validation behavior and visibility' do
    context 'where build! is used' do
      it 'validates immediately and raises an error on invalid values' do
        person_class = described_class.define do
          name String
          age  Integer
        end

        expect {
          person_class.build!( name: 'Alice', age: 'not-an-integer' )
        }.to raise_error( DynamicSchema::IncompatibleTypeError )
      end
    end

    context 'where build is used' do
      it 'does not validate immediately but exposes validation helpers' do
        person_class = described_class.define do
          name String
          age  Integer
        end

        person = person_class.build( name: 'Bob', age: 'not-an-integer' )
        expect( person.age ).to eq( nil )
        expect( person.valid? ).to be false
        expect( person.validate ).to all( be_a( DynamicSchema::Error ) )
        expect { person.validate! }.to raise_error( DynamicSchema::IncompatibleTypeError )
      end
    end
  end

  context 'nested validation cases' do
    context 'where a nested object is required and contains typed fields' do
      it 'validates presence of the object and types within it' do
        account_class = described_class.define do
          profile required: true do
            username String
            age      Integer
          end
        end

        missing = account_class.build
        expect( missing.valid? ).to be false
        expect( missing.validate.map( &:class ) ).to include( DynamicSchema::RequiredOptionError )

        wrong_type = account_class.build( profile: { username: 'a', age: 'x' } )
        expect( wrong_type.valid? ).to be false
        expect { wrong_type.validate! }.to raise_error( DynamicSchema::IncompatibleTypeError )
      end
    end

    context 'where the :in option is used inside nested objects' do
      it 'validates that values are included in the given set' do
        settings_class = described_class.define do
          preferences do
            state Symbol, in: [ :on, :off ]
          end
        end

        instance = settings_class.build( preferences: { state: 'maybe' } )
        errors = instance.validate
        expect( errors ).not_to be_empty
        expect( errors.first ).to be_a( DynamicSchema::InOptionError )
      end
    end

    context 'where arrays of nested objects are used' do
      it 'validates each element within the array' do
        catalog_class = described_class.define do
          products array: true do
            price Integer
          end
        end

        invalid = catalog_class.build( products: [ { price: 1 }, { price: 'two' } ] )
        expect( invalid.valid? ).to be false
        expect { invalid.validate! }.to raise_error( DynamicSchema::IncompatibleTypeError )

        valid = catalog_class.build( products: [ { price: 1 }, { price: 2 } ] )
        expect( valid.valid? ).to be true
        expect( valid.validate ).to be_empty
      end
    end
  end

end
