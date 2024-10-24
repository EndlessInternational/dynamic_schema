require 'spec_helper'

RSpec.describe DynamicSchema::Builder do
  describe 'object attributes with :arguments option' do

    context 'where the object has a single value' do
      it 'defines and builds the attributes correctly' do
        builder = described_class.new.define do 
          object arguments: :value do 
            value 
          end
        end 
        result = builder.build do 
          object :one
        end
        expect( result[ :object ][ :value ] ).to eq( :one )
      end
    end

    context 'where the object has a mutliple values' do
      
      context 'where the object has arguments for all values' do
        it 'defines and builds the attributes correctly' do
          builder = described_class.new.define do 
            object arguments: [ :value, :other_value ] do 
              value 
              other_value
            end
          end 
          result = builder.build do 
            object :one, :two 
          end
          expect( result[ :object ][ :value ] ).to eq( :one )
          expect( result[ :object ][ :other_value ] ).to eq( :two )
        end
      end
      
      context 'where the object has arguments for some values' do
        it 'defines and builds the attributes correctly' do
          builder = described_class.new.define do 
            object arguments: [ :value, :second_value ] do 
              value 
              second_value
              third_value
            end
          end 
          result = builder.build do 
            object :one, :two do 
              third_value :three
            end
          end
          expect( result[ :object ][ :value ] ).to eq( :one )
          expect( result[ :object ][ :second_value ] ).to eq( :two )
          expect( result[ :object ][ :third_value ] ).to eq( :three )
        end
      end

      context 'where the object has arguments for some values and an attributes hash' do
        it 'defines and builds the attributes correctly' do
          builder = described_class.new.define do 
            object arguments: [ :value, :second_value ] do 
              value 
              second_value 
              third_value 
              fourth_value
            end
          end 
          result = builder.build! do 
            object :one, :two, third_value: :three do 
              fourth_value :four
            end
          end
          expect( result[ :object ][ :value ] ).to eq( :one )
          expect( result[ :object ][ :second_value ] ).to eq( :two )
          expect( result[ :object ][ :third_value ] ).to eq( :three )
          expect( result[ :object ][ :fourth_value ] ).to eq( :four )
        end
      end

    end

    context 'where the object has an :array option' do 

      context 'where the object has a single value' do
        it 'defines and builds the attributes correctly' do
          builder = described_class.new.define do 
            object arguments: :value, array: true do 
              value 
            end
          end 
          result = builder.build do 
            object :one_one
            object :two_one
          end
          expect( result[ :object ][0][ :value ] ).to eq( :one_one )
          expect( result[ :object ][1][ :value ] ).to eq( :two_one )
        end
      end

      context 'where the object has a mutliple values' do
        
        context 'where the object has arguments for all values' do
          it 'defines and builds the attributes correctly' do
            builder = described_class.new.define do 
              object arguments: [ :value, :other_value ], array: true do 
                value 
                other_value
              end
            end 
            result = builder.build do 
              object :one_one, :one_two 
              object :two_one, :two_two
            end
            expect( result[ :object ][0][ :value ] ).to eq( :one_one )
            expect( result[ :object ][0][ :other_value ] ).to eq( :one_two )
            expect( result[ :object ][1][ :value ] ).to eq( :two_one )
            expect( result[ :object ][1][ :other_value ] ).to eq( :two_two )
          end
        end
        
        context 'where the object has arguments for some values' do
          it 'defines and builds the attributes correctly' do
            builder = described_class.new.define do 
              object arguments: [ :value, :second_value ], array: true do 
                value 
                second_value
                third_value
              end
            end 
            result = builder.build do 
              object :one_one, :one_two do 
                third_value :one_three
              end
              object :two_one, :two_two do 
                third_value :two_three
              end
            end
            expect( result[ :object ][0][ :value ] ).to eq( :one_one )
            expect( result[ :object ][0][ :second_value ] ).to eq( :one_two )
            expect( result[ :object ][0][ :third_value ] ).to eq( :one_three )
            expect( result[ :object ][1][ :value ] ).to eq( :two_one )
            expect( result[ :object ][1][ :second_value ] ).to eq( :two_two )
            expect( result[ :object ][1][ :third_value ] ).to eq( :two_three )
          end
        end

        context 'where the object has arguments for some values and an attributes hash' do
          it 'defines and builds the attributes correctly' do
            builder = described_class.new.define do 
              object arguments: [ :value, :second_value ], array: true do 
                value 
                second_value 
                third_value 
                fourth_value
              end
            end 
            result = builder.build! do 
              object :one_one, :one_two, third_value: :one_three do 
                fourth_value :one_four
              end
              object :two_one, :two_two, third_value: :two_three do 
                fourth_value :two_four
              end
           end
            expect( result[ :object ][0][ :value ] ).to eq( :one_one )
            expect( result[ :object ][0][ :second_value ] ).to eq( :one_two )
            expect( result[ :object ][0][ :third_value ] ).to eq( :one_three )
            expect( result[ :object ][0][ :fourth_value ] ).to eq( :one_four )
            expect( result[ :object ][1][ :value ] ).to eq( :two_one )
            expect( result[ :object ][1][ :second_value ] ).to eq( :two_two )
            expect( result[ :object ][1][ :third_value ] ).to eq( :two_three )
            expect( result[ :object ][1][ :fourth_value ] ).to eq( :two_four )
          end
        end

      end

    end

  end
end
