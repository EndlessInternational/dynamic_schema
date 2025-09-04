require 'spec_helper'

RSpec.describe DynamicSchema::Builder do
  context '#validate' do

    context 'with a builder defining a single paramter' do
      context 'with a parameter that includes a :type option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            a_parameter type: Integer
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )
          
          result = builder.validate( { a_parameter: 'nan' } )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )

          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( false )
        end
      end
      context 'with a parameter that includes a :required option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            a_parameter required: true 
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )
          expect( builder.validate( { a_parameter: 'nan' } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( true )

          result = builder.validate( {} )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( DynamicSchema::RequiredOptionError )

          expect( builder.valid?( {} ) ).to eq( false )
        end
      end
      context 'with a parameter that includes a :in option' do
        context 'with a parameter without a type' do 
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameter in: [ :one, :two, :three ]  
            end

            expect( builder.validate( { a_parameter: :one } ) ).to eq( [] )
            expect( builder.valid?( { a_parameter: :one } ) ).to eq( true )

            build = builder.build { a_parameter 'two' }
            result = builder.validate( build )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
            expect( builder.valid?( build ) ).to eq( false )

            result = builder.validate( { a_parameter: :zero } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
            expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
            expect( builder.valid?( {} ) ).to eq( true )
          end
        end
        context 'with a parameter with a non-Numeric type' do 
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameter Symbol, in: [ :one, :two, :three ]  
            end

            expect( builder.validate( { a_parameter: :one } ) ).to eq( [] )
            expect( builder.valid?( { a_parameter: :one } ) ).to eq( true )

            build = builder.build { a_parameter 'two' }
            expect( builder.validate( build ) ).to eq( [] )
            expect( builder.valid?( build ) ).to eq( true )

            result = builder.validate( { a_parameter: :zero } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
            expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
            expect( builder.valid?( {} ) ).to eq( true )
          end
        end
        context 'with a parameter with a Numeric type' do 
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameter Integer, in: 1..10 
            end

            expect( builder.validate( { a_parameter: 1 } ) ).to eq( [] )
            expect( builder.valid?( { a_parameter: 1 } ) ).to eq( true )

            result = builder.validate( { a_parameter: 0 } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
            expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
            expect( builder.valid?( {} ) ).to eq( true )
          end
        end
        context 'with a parameter with an array option' do 
          context 'with a parameter without a type' do 
            it 'validates the parameter' do
              builder = construct_builder do 
                a_parameter array: true, in: [ :one, :two, :three ]  
              end

              expect( builder.validate( { a_parameter: [ :one ] } ) ).to eq( [] )
              expect( builder.valid?( { a_parameter: [ :one ] } ) ).to eq( true )

              build = builder.build { a_parameter 'two' }
              result = builder.validate( build )
              expect( result ).to be_a( Array )
              expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
              expect( builder.valid?( build ) ).to eq( false )

              result = builder.validate( { a_parameter: :zero } )
              expect( result ).to be_a( Array )
              expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
              expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

              result = builder.validate( {} )
              expect( result ).to eq( [] )
              expect( builder.valid?( {} ) ).to eq( true )
            end
          end
          context 'with a parameter with a non-Numeric type' do 
            it 'validates the parameter' do
              builder = construct_builder do 
                a_parameter Symbol, array: true, in: [ :one, :two, :three ]  
              end

              expect( builder.validate( { a_parameter: [ :one ] } ) ).to eq( [] )
              expect( builder.valid?( { a_parameter: [ :one ] } ) ).to eq( true )

              build = builder.build { a_parameter 'two' }
              expect( builder.validate( build ) ).to eq( [] )
              expect( builder.valid?( build ) ).to eq( true )

              result = builder.validate( { a_parameter: :zero } )
              expect( result ).to be_a( Array )
              expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
              expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

              result = builder.validate( {} )
              expect( result ).to eq( [] )
              expect( builder.valid?( {} ) ).to eq( true )            
            end
          end
          context 'with a parameter with a Numeric type' do 
            it 'validates the parameter' do
              builder = construct_builder do 
                a_parameter Integer, array: true, in: 1..10 
              end

              expect( builder.validate( { a_parameter: [ 1 ] } ) ).to eq( [] )
              expect( builder.valid?( { a_parameter: [ 1 ] } ) ).to eq( true )

              build = builder.build { a_parameter 0 } 
              result = builder.validate( build )
              expect( result ).to be_a( Array )
              expect( result[ 0 ] ).to be_a( DynamicSchema::InOptionError )
              expect( builder.valid?( { a_parameter: 0 } ) ).to eq( false )

              result = builder.validate( {} )
              expect( result ).to eq( [] )
              expect( builder.valid?( {} ) ).to eq( true )            
            end
          end    
        end
      end
      context 'with a parameter that includes a :type and a :required option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            a_parameter type: Integer, required: true 
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )

          result = builder.validate( { a_parameter: 'nan' } )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )
          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( false )

          result = builder.validate( {} )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( DynamicSchema::RequiredOptionError )
          expect( builder.valid?( {} ) ).to eq( false )
        end
      end
    end

    context 'with a builder defining a single parameter inside parameters' do
      context 'with parameters that is not required' do 
        context 'with parameter that includes a :type option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters do 
                a_parameter type: Integer
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_parameters: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )
          end
        end
        context 'with a parameter that includes a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters do 
                a_parameter required: true
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )
            expect( builder.validate( { a_parameters: { a_parameter: 'nan' } } ) ).to eq( [] )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
          end
        end
        context 'with a parameter that includes a :type and a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters do 
                a_parameter type: Integer, required: true
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_parameters: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
          end
        end
      end
      context 'with parameters that is required' do 
        context 'with a parameter that includes a :type option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters required: true do 
                a_parameter type: Integer
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_parameters: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )
          end
        end
        context 'with parameter that includes a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters required: true do 
                a_parameter required: true
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )
            expect( builder.validate( { a_parameters: { a_parameter: 'nan' } } ) ).to eq( [] )

            result = builder.validate( {} )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::RequiredOptionError )
          end
        end
        context 'with parameter that includes a :type and a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              a_parameters required: true do 
                a_parameter type: Integer, required: true
              end
            end

            expect( builder.validate( { a_parameters: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_parameters: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::IncompatibleTypeError )

            result = builder.validate( {} )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( DynamicSchema::RequiredOptionError )
          end
        end
      end
     end

  end
end
