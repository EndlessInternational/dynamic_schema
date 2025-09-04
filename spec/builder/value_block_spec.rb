require 'spec_helper'

RSpec.describe DynamicSchema::Builder do
  context 'value blocks' do

    context 'where a class with an attribute accessor is given as a schema value type' do
      
      context 'where the class instance is given for the value when building the schema' do 
        context 'where the value includes a block with an attribute assigment' do 
          it 'applies the attribute in the block' do
            class Customer
              attr_accessor :name
            end

            builder = described_class.new.define do
              customer Customer
            end

            result = builder.build! do
              customer Customer.new do
                name 'Kristoph'
              end
            end

            expect( result[ :customer ] ).to be_a( Customer )
            expect( result[ :customer ].name ).to eq( 'Kristoph' )
          end
        end
      end

      context 'where the class instance is not given for the value when building the schema' do 
        context 'where the value includes a block with an attribute assigment' do 
          it 'applies the attribute in the block' do
            class Customer
              attr_accessor :name
            end

            builder = described_class.new.define do
              customer Customer
            end

            result = builder.build! do
              customer do
                name 'Kristoph'
              end
            end

            expect( result[ :customer ] ).to be_a( Customer )
            expect( result[ :customer ].name ).to eq( 'Kristoph' )
          end
        end
      end

      context 'where a class without an attribute accessor is given as a schema value type' do
        
        context 'where the class instance is given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'raises a NoMethodError' do
              class Customer
                # no attribute accessor
              end

              builder = described_class.new.define do
                customer Customer
              end

              expect {
                builder.build! do
                  customer Customer do
                    name 'Kristoph'
                  end
                end
              }.to raise_error( NoMethodError, /cannot be assigned/ )
            end
          end
        end

        context 'where the class instance is not given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'raises a NoMethodError' do
              class Customer
                # no attribute accessor
              end

              builder = described_class.new.define do
                customer Customer
              end

              expect {
                builder.build! do
                  customer Customer do
                    name 'Kristoph'
                  end
                end
              }.to raise_error( NoMethodError, /cannot be assigned/ )
            end
          end
        end

      end

    end

    context 'where a class with an attribute accessor is given as a schema value type' do

      context 'where the value is defined with the :array option' do

        context 'where the class instance is given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'applies the attribute in the block and includes these in the result' do
              class Customer
                attr_accessor :name
              end

              builder = described_class.new.define do
                customer Customer, array: true
              end

              result = builder.build! do
                customer Customer.new do
                  name 'Kristoph'
                end
              end

              expect( result[ :customer ] ).to be_a( Array )
              expect( result[ :customer ][0] ).to be_a( Customer )
              expect( result[ :customer ][0].name ).to eq( 'Kristoph' )
            end
          end
        end

        context 'where the class instance is not given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'applies the attribute in the block and includes these in the result' do
              class Customer
                attr_accessor :name
              end

              builder = described_class.new.define do
                customer Customer, array: true
              end

              result = builder.build! do
                customer do
                  name 'Kristoph'
                end
              end

              expect( result[ :customer ] ).to be_a( Array )
              expect( result[ :customer ][0] ).to be_a( Customer )
              expect( result[ :customer ][0].name ).to eq( 'Kristoph' )
            end
          end
        end

        context 'where multiple class instances are given for the value when building the schema' do 

          context 'where the value does not include a block with an attribute assigment' do 
            it 'includes all instances in the result' do
              class Customer
                attr_accessor :name
                def initialize( name: nil )
                  @name = name  
                end
              end

              builder = described_class.new.define do
                customer Customer, array: true
              end

              result = builder.build! do
                customer [ Customer.new( name: 'Kristoph' ), Customer.new( name: 'Ayuka' ) ]
              end

              expect( result[ :customer ] ).to be_a( Array )
              expect( result[ :customer ].length ).to eq( 2 )

              expect( result[ :customer ][0] ).to be_a( Customer )
              expect( result[ :customer ][0].name ).to eq( 'Kristoph' )

              expect( result[ :customer ][1] ).to be_a( Customer )
              expect( result[ :customer ][1].name ).to eq( 'Ayuka' )
            end
          end

          context 'where the value includes a block with an attribute assigment' do 
            it 'applies the attribute in the block to each instance' do
              class Customer
                attr_accessor :name
                attr_accessor :adult
              end

              builder = described_class.new.define do
                customer Customer, array: true
              end

              result = builder.build! do
                customer [ Customer.new( name: 'Kristoph' ), Customer.new( name: 'Ayuka' ) ] do
                  adult true
                end
              end

              expect( result[ :customer ] ).to be_a( Array )
              expect( result[ :customer ].length ).to eq( 2 )

              expect( result[ :customer ][0] ).to be_a( Customer )
              expect( result[ :customer ][0].name ).to eq( 'Kristoph' )
              expect( result[ :customer ][0].adult ).to eq( true )

              expect( result[ :customer ][1] ).to be_a( Customer )
              expect( result[ :customer ][1].name ).to eq( 'Ayuka' )
              expect( result[ :customer ][1].adult ).to eq( true )
            end
          end
        end

      end

      context 'where the value is defined with the :array option and an :as option' do
        context 'where the class instance is given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'applies the attribute in the block' do
              class Customer
                attr_accessor :name
              end

              builder = described_class.new.define do
                customer Customer, array: true, as: :customers
              end

              result = builder.build! do
                customer Customer.new do
                  name 'Kristoph'
                end
              end

              expect( result[ :customers ] ).to be_a( Array )
              expect( result[ :customers ][0] ).to be_a( Customer )
              expect( result[ :customers ][0].name ).to eq( 'Kristoph' )
            end
          end
        end

        context 'where the class instance is not given for the value when building the schema' do 
          context 'where the value includes a block with an attribute assigment' do 
            it 'applies the attribute in the block' do
              class Customer
                attr_accessor :name
              end

              builder = described_class.new.define do
                customer Customer, array: true, as: :customers
              end

              result = builder.build! do
                customer do
                  name 'Kristoph'
                end
              end

              expect( result[ :customers ] ).to be_a( Array )
              expect( result[ :customers ][0] ).to be_a( Customer )
              expect( result[ :customers ][0].name ).to eq( 'Kristoph' )
            end
          end
        end
      end

    end

    context 'where a class initializer requires arguments' do 
      context 'where the class instance is not given for the value when building the schema' do 
        context 'where the value includes a block with an attribute assigment' do 
          it 'raises an ArgumentError indicating construction failed' do
            class Customer
              attr_accessor :name
              def initialize( required: )
                @name = nil
              end
            end

            builder = described_class.new.define do
              customer Customer
            end

            expect {
              builder.build! do
                customer do
                  name 'Kristoph'
                end
              end
            }.to raise_error( TypeError, /could not be constructed/ )
          end
        end
      end
    end

    context 'where the type is declared as a single-item type array' do
      context 'where the class instance is not given for the value when building the schema' do 
        context 'where the value includes a block with an attribute assigment' do 
          it 'instantiates the type and applies the attribute in the block' do
            class Customer
              attr_accessor :name
              # override any previous initializer that required keywords
              def initialize; end
            end

            builder = described_class.new.define do
              customer [ Customer ]
            end

            result = builder.build! do
              customer do
                name 'Kristoph'
              end
            end

            expect( result[ :customer ] ).to be_a( Customer )
            expect( result[ :customer ].name ).to eq( 'Kristoph' )
          end
        end
      end
    end

    context 'where multiple possible types are declared for the value' do
      context 'where the class instance is not given for the value when building the schema' do 
        context 'where the value includes a block with an attribute assigment' do 
          it 'raises an ArgumentError indicating explicit value is required' do
            class Customer
              attr_accessor :name
            end

            builder = described_class.new.define do
              customer [ Customer, String ]
            end

            expect {
              builder.build! do
                customer do
                  name 'Kristoph'
                end
              end
            }.to raise_error( TypeError, /multiple types were specified/ )
          end
        end
      end
    end

    context 'where the value type is a scalar (e.g. String) and a block is used' do
      context 'where the value includes a block with an attribute assigment' do 
        it 'raises a NoMethodError because the target has no writer' do
          builder = described_class.new.define do
            param String
          end

          expect {
            builder.build! do
              param 'value' do
                name 'Kristoph'
              end
            end
          }.to raise_error( NoMethodError, /cannot be assigned/ )
        end
      end
    end

    context 'where an incorrect instance type is provided' do
      context 'where the value includes a block with an attribute assigment' do 
        it 'raises a NoMethodError against the provided target' do
          class Customer
            attr_accessor :name
          end

          builder = described_class.new.define do
            customer Customer
          end

          expect {
            builder.build! do
              customer 'not a customer' do
                name 'Kristoph'
              end
            end
          }.to raise_error( NoMethodError, /cannot be assigned/ )
        end
      end
    end

    context 'where a setter is called without a value inside the block' do 
      it 'raises an ArgumentError indicating 1 argument is required' do
        class Customer
          attr_accessor :name
        end

        builder = described_class.new.define do
          customer Customer
        end

        expect {
          builder.build! do
            customer Customer.new do
              name
            end
          end
        }.to raise_error( ArgumentError, /requires 1 argument/ )
      end
    end

    context 'array values with non-object entries and a block' do
      it 'raises a NoMethodError when attempting to assign on a Hash' do
        class Customer
          attr_accessor :name
        end

        builder = described_class.new.define do
          customer Customer, array: true
        end

        expect {
          builder.build! do
            customer [ { name: 'Existing' } ] do
              name 'New'
            end
          end
        }.to raise_error( NoMethodError, /cannot be assigned/ )
      end
    end

    context 'array values with nil and a block' do
      it 'instantiates an item and applies the attribute' do
        class Customer
          attr_accessor :name
        end

        builder = described_class.new.define do
          customer Customer, array: true
        end

        result = builder.build! do
          customer nil do
            name 'Kristoph'
          end
        end

        expect( result[ :customer ] ).to be_a( Array )
        expect( result[ :customer ].length ).to eq( 1 )
        expect( result[ :customer ][0] ).to be_a( Customer )
        expect( result[ :customer ][0].name ).to eq( 'Kristoph' )
      end
    end

  end
end
