require 'spec_helper'

RSpec.describe DynamicSchema::Struct do

  context 'run time type information' do
    context 'where a struct class is generated' do
      it 'includes DynamicSchema::Struct::Class in generated classes' do
        person_class = described_class.define do
          name String
        end

        expect( person_class.included_modules ).to include( DynamicSchema::Struct::Class )

        instance = person_class.build( name: 'Xavier' )
        expect( instance ).to be_a( DynamicSchema::Struct::Class )
      end
    end
  end

end
