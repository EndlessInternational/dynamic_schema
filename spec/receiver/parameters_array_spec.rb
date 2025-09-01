require 'spec_helper.rb'

RSpec.describe DynamicSchema::Receiver::Object do

  describe 'parameters array' do
    context 'when a parameters array is defined' do 

      let( :schema ) {
        {
          message: {
            type: Object, 
            array: true,
            schema: {
              role: {},
              text: { type: String }
            }
          }
        }
      }
          
      context 'when the parameters are called once' do
        context 'through a builder' do
          it 'results in an array of hashes' do 
            receiver = build_receiver( schema: schema )

            receiver.message do 
              role :system
              text 'text'
            end 
            
            result = receiver.to_h 
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 1 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end

        context 'through attributes' do 
          it 'includes an array of hashes' do 
            attributes = { message: [ { role: :system, text: 'text' } ] }
            receiver = build_receiver( attributes, schema: schema )

            result = receiver.to_h
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 1 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end
      end

      context 'when parameters are called multiple times' do
        context 'through a builder' do
          it 'includes an array of mulitple hashes' do 
            receiver = build_receiver( schema: schema )

            receiver.message do 
              role :system
              text 'text 0'
            end 
            receiver.message do 
              role :user
              text 'text 1'
            end 
            
            result = receiver.to_h
            expect( result[ :message ] ).to_not be_nil
            
            receiver.message do 
              role :assistant
              text 'text 2'
            end 
            
            result = receiver.to_h
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 3 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text 0' )
            expect( result[ :message ][ 2 ][ :role ] ).to eq( :assistant )
            expect( result[ :message ][ 2 ][ :text ] ).to eq( 'text 2' )
          end
        end

        context 'through attributes' do 
          it 'includes an array of multiple hashes' do 
            attributes = { 
              message: [ 
                { role: :system, text: 'text 0' }, 
                { role: :user, text: 'text 1' }, 
                { role: :assistant, text: 'text 2' } 
              ] 
            }
            receiver = build_receiver( attributes, schema: schema )

            result = receiver.to_h
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 3 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text 0' )
            expect( result[ :message ][ 2 ][ :role ] ).to eq( :assistant )
            expect( result[ :message ][ 2 ][ :text ] ).to eq( 'text 2' )
          end
        end
      end
    end
  end

  describe 'parameters with array option nested in parameters with array option' do
    context 'when configured with a parameters array inside a parameters array' do 

      let( :schema ) {
        {
          message: {
            type: Object, 
            array: true,
            schema: {
              role: {},
              content: {
                type: Object,
                array: true,
                schema: {
                  text: { type: String }
                }
              }
            }
          }
        }
      }
          
      context 'when one array parameters entry is given' do
        context 'with one array parameters entry inside that parameters' do 
          context 'when using a builder' do 
            it 'configures the context with the outer and inner entry' do 
              receiver = build_receiver( schema: schema )
              
              receiver.message do 
                role :system
                content do 
                  text 'text'
                end
              end 

              result = receiver.to_h
              message = result[ :message ]
              expect( message ).to_not be_nil
              expect( message ).to be_a( Array )
              expect( message.count ).to eq( 1 )
              expect( message[ 0 ][ :role ] ).to eq( :system )

              content = result[ :message ][ 0 ][ :content ]
              expect( content ).to_not be_nil
              expect( content ).to be_a( Array )
              expect( content.count )
            end
          end

          context 'when using attributes' do 
            it 'configures the context with the outer and inner entry' do 
              attributes = { message: [ { role: :system, content: [ { text: 'text' } ] } ] }
              receiver = build_receiver( attributes, schema: schema )

              result = receiver.to_h
              message = result[ :message ]
              expect( message ).to_not be_nil
              expect( message ).to be_a( Array )
              expect( message.count ).to eq( 1 )
              expect( message[ 0 ][ :role ] ).to eq( :system )

              content = result[ :message ][ 0 ][ :content ]
              expect( content ).to_not be_nil
              expect( content ).to be_a( Array )
              expect( content.count )
            end
          end 
        end
      end
  
    end
  end

  describe 'parameters types with array option and as option' do
    context 'when configured with a parameters array' do 

      let( :schema ) {
        {
          message: {
            type: Object, 
            array: true,
            as: :messages,
            schema: {
              role: {},
              text: { type: String }
            }
          }
        }
      }
          
      context 'when one array parameters entry is given' do
        context 'when using a builder' do
          it 'configures the context with the entry' do 
            receiver = build_receiver( schema: schema )
 
            receiver.message do 
              role :system
              text 'text'
            end

            result = receiver.to_h
            expect( result[ :messages ] ).to_not be_nil
            expect( result[ :messages ] ).to be_a( Array )
            expect( result[ :messages ].count ).to eq( 1 )
            expect( result[ :messages ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :messages ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end

        context 'when using a attributes' do 
          it 'configures the context with the entry' do 
            attributes = { message: [ { role: :system, text: 'text' } ] }
            receiver = build_receiver( attributes, schema: schema )

            result = receiver.to_h
            expect( result[ :messages ] ).to_not be_nil
            expect( result[ :messages ] ).to be_a( Array )
            expect( result[ :messages ].count ).to eq( 1 )
            expect( result[ :messages ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :messages ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end
      end

    end
  end

  describe 'parameters types with array option and as option nested in parameters with array option and as option' do
    context 'when configured with a parameters array inside a parameters array' do 

      let( :schema ) {
        {
          message: {
            type: Object, 
            array: true,
            as: :messages,
            schema: {
              role: {},
              content: {
                type: Object,
                array: true,
                as: :contents,
                schema: {
                  text: { type: String }
                }
              }
            }
          }
        }
      }
          
      context 'when one array parameters entry is given' do
        context 'with one array parameters entry inside that parameters' do 
          context 'when using a builder' do 
            it 'configures the context with the outer and inner entry' do 
              receiver = build_receiver( schema: schema )
              
              receiver.message do 
                role :system
                content do 
                  text 'text'
                end
              end 

              result = receiver.to_h

              messages = result[ :messages ]
              expect( messages ).to_not be_nil
              expect( messages ).to be_a( Array )
              expect( messages.count ).to eq( 1 )
              expect( messages[ 0 ][ :role ] ).to eq( :system )

              contents = result[ :messages ][ 0 ][ :contents ]
              expect( contents ).to_not be_nil
              expect( contents ).to be_a( Array )
              expect( contents.count )
            end
          end

          context 'when using attributes' do 
            it 'configures the context with the outer and inner entry' do 
              attributes = { message: [ { role: :system, content: [ { text: 'text' } ] } ] }
              receiver = build_receiver( attributes, schema: schema )

              result = receiver.to_h
                
              messages = result[ :messages ]
              expect( messages ).to_not be_nil
              expect( messages ).to be_a( Array )
              expect( messages.count ).to eq( 1 )
              expect( messages[ 0 ][ :role ] ).to eq( :system )

              contents = result[ :messages ][ 0 ][ :contents ]
              expect( contents ).to_not be_nil
              expect( contents ).to be_a( Array )
              expect( contents.count )
            end
          end 
        end
      end
  
    end
  end
end
