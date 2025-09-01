require 'spec_helper.rb'

RSpec.describe DynamicSchema::Receiver::Object do

  describe 'parameters with arguments' do

    it 'handles nil parameters argument correctly' do
      schema = {
        group_a: {
          type: Object,
          schema: {
            value_a: {
              type: String
            }
          }
        }
      }
      receiver = build_receiver( schema: schema )
     
      receiver.group_a
      expect( receiver.to_h[ :group_a ][ :value_a ] ).to eq( nil )
      receiver.group_a nil
      expect( receiver.to_h[ :group_a ][ :value_a ] ).to eq( nil )
    end

    it 'handles values inside parameters correctly' do
      schema = {
        group_a: {
          type: Object,
          schema: {
            value_a: {
              type: String
            }
          }
        }
      }
      receiver = build_receiver( schema: schema )

      receiver.group_a( value_a: 'A' )
      expect( receiver.to_h[ :group_a ][ :value_a ] ).to eq( 'A' )
    end

    it 'handles values inside paramters inside parameters correctly' do
      schema = {
        group_a: {
          type: Object,
          schema: {
            value_a: {
              type: String
            },
            group_b: {
              type: Object,
              schema: {
                value_b: {
                  type: String
                }
              }
            }
          }
        }
      }
      receiver = build_receiver( schema: schema )
      
      receiver.group_a( value_a: 'A', group_b: { value_b: 'B' } )
      expect( receiver.to_h[ :group_a ][ :value_a ] ).to eq( 'A' )
      expect( receiver.to_h[ :group_a ][ :group_b ][ :value_b ] ).to eq( 'B' )
    end

  end
end
