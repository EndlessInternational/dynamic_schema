require 'spec_helper'

RSpec.describe DynamicSchema::Builder do

  describe 'value attribute types' do

    it 'defines and builds untyped value attributes correctly' do
      builder = described_class.new.define do
        param 
      end

      result = builder.build! do
        param 'value'
      end
      expect( result[ :param ] ).to eq( 'value' )

      result = builder.build! do
        param test: 'value'
      end
      expect( result[ :param ][ :test ] ).to eq( 'value' )
    end

    it 'defines builds String value attributes correctly' do
      builder = described_class.new.define do
        string_param String
      end

      result = builder.build! do
        string_param 'test-string'
      end

      expect( result[ :string_param ] ).to eq( 'test-string' )
    end

    it 'defines and builds Integer value attributes correctly' do
      builder = described_class.new.define do
        integer_param Integer
      end

      result = builder.build! do
        integer_param 42
      end

      expect( result[ :integer_param ] ).to eq( 42 )
    end

    it 'defines and builds Float value attributes correctly' do
      builder = described_class.new.define do
        float_param Float
      end

      result = builder.build! do
        float_param 3.14
      end

      expect( result[ :float_param ] ).to eq( 3.14 )
    end

    it 'defines and builds boolean ( TrueClass, FalseClass ) value attributes correctly' do
      builder = described_class.new.define do
        boolean_param [ TrueClass, FalseClass ]
      end

      result = builder.build! do
        boolean_param true
      end

      expect( result[ :boolean_param ] ).to eq( true )
    end

    it 'defines and builds custom class instance value attributes correctly' do
      class CustomType
        attr_reader :value
        def initialize( value )
          @value = value
        end
      end

      builder = described_class.new.define do
        custom_param CustomType
      end

      custom_value = CustomType.new( 'custom' )
      result = builder.build! do
        custom_param custom_value
      end

      expect( result[ :custom_param ] ).to eq( custom_value )
      expect( result[ :custom_param ].value ).to eq( 'custom' )
    end

    context 'where a value attribute is encasulated in an object attribute block' do

      it 'defines and builds untyped value attributes correctly' do
        builder = described_class.new.define do
          object do  
            param
          end
        end

        result = builder.build! do
          object do 
            param 'value'
          end
        end
        expect( result[ :object ][ :param ] ).to eq( 'value' )

        result = builder.build! do
          object do 
            param test: 'value'
          end
        end
        expect( result[ :object ][ :param ][ :test ] ).to eq( 'value' )
      end

      it 'defines builds String value attributes correctly' do
        builder = described_class.new.define do
          object do 
            string_param String
          end
        end

        result = builder.build! do
          object do 
            string_param 'test-string'
          end
        end

        expect( result[ :object ][ :string_param ] ).to eq( 'test-string' )
      end

      it 'defines and builds Integer value attributes correctly' do
        builder = described_class.new.define do
          object do 
            integer_param Integer
          end
        end

        result = builder.build! do
          object do
            integer_param 42
          end
        end

        expect( result[ :object ][ :integer_param ] ).to eq( 42 )
      end

      it 'defines and builds Float value attributes correctly' do
        builder = described_class.new.define do
          object do 
            float_param Float
          end
        end

        result = builder.build! do
          object do 
            float_param 3.14
          end
        end

        expect( result[ :object ][ :float_param ] ).to eq( 3.14 )
      end

      it 'defines and builds boolean ( TrueClass, FalseClass ) value attributes correctly' do
        builder = described_class.new.define do
          object do 
            boolean_param [ TrueClass, FalseClass ]
          end
        end

        result = builder.build! do
          object do
            boolean_param true
          end
        end

        expect( result[ :object ][ :boolean_param ] ).to eq( true )
      end

      it 'defines and builds custom class instance value attributes correctly' do
        class CustomType
          attr_reader :value
          def initialize( value )
            @value = value
          end
        end

        builder = described_class.new.define do
          object do 
            custom_param CustomType
          end
        end

        custom_value = CustomType.new( 'custom' )
        result = builder.build! do
          object do 
            custom_param custom_value
          end
        end

        expect( result[ :object ][ :custom_param ] ).to eq( custom_value )
        expect( result[ :object ][ :custom_param ].value ).to eq( 'custom' )
      end

    end 

  end 
end
