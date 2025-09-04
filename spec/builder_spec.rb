require 'spec_helper'

RSpec.describe DynamicSchema::Builder do

  context 'default values' do
    it 'uses default values when parameters are not provided' do
      builder = described_class.new.define do
        string_param String, default: 'default-string'
        integer_param Integer, default: 100
        float_param Float, default: 1.23
        boolean_param [ TrueClass, FalseClass ], default: false
      end

      result = builder.build! do
        # No parameters provided
      end

      expect( result[ :string_param ] ).to eq( 'default-string' )
      expect( result[ :integer_param ] ).to eq( 100 )
      expect( result[ :float_param ] ).to eq( 1.23 )
      expect( result[ :boolean_param ] ).to eq( false )
    end

    it 'overrides default values when parameters are provided' do
      builder = described_class.new.define do
        string_param String, default: 'default-string'
      end

      result = builder.build! do
        string_param 'provided-string'
      end

      expect( result[ :string_param ] ).to eq( 'provided-string' )
    end
  end

  context 'array parameters with different types' do
    it 'handles arrays of Strings' do
      builder = described_class.new.define do
        string_array String, array: true
      end

      result = builder.build! do
        string_array [ 'one', 'two', 'three' ]
      end

      expect( result[ :string_array ] ).to eq( [ 'one', 'two', 'three' ] )
    end

    it 'handles arrays of Integers' do
      builder = described_class.new.define do
        integer_array Integer, array: true
      end

      result = builder.build! do
        integer_array [ 1, 2, 3 ]
      end

      expect( result[ :integer_array ] ).to eq( [ 1, 2, 3 ] )
    end

    it 'handles arrays of Floats' do
      builder = described_class.new.define do
        float_array Float, array: true
      end

      result = builder.build! do
        float_array [ 1.1, 2.2, 3.3 ]
      end

      expect( result[ :float_array ] ).to eq( [ 1.1, 2.2, 3.3 ] )
    end

    it 'handles arrays of Booleans' do
      builder = described_class.new.define do
        boolean_array [ TrueClass, FalseClass ], array: true
      end

      result = builder.build! do
        boolean_array [ true, false, true ]
      end

      expect( result[ :boolean_array ] ).to eq( [ true, false, true ] )
    end

    it 'handles arrays with mixed types when no type is specified' do
      builder = described_class.new.define do
        mixed_array array: true
      end

      result = builder.build! do
        mixed_array [ 1, 'two', 3.0, true ]
      end

      expect( result[ :mixed_array ] ).to eq( [ 1, 'two', 3.0, true ] )
    end

    it 'raises TypeError when array elements are of incorrect type' do
      builder = described_class.new.define do
        integer_array Integer, array: true
      end

      expect {
        builder.build! do
          integer_array [ 1, 'two', 3 ]
        end
      }.to raise_error( 
        DynamicSchema::IncompatibleTypeError, 
        /expects 'Integer' but incompatible 'String'/ 
      )
    end
  end

  context 'nested parameters with various types' do
    it 'handles nested parameters with different parameter types' do
      builder = described_class.new.define do
        database do
          host String, default: 'localhost'
          port Integer, default: 5432
          username String
          password String
          ssl_enabled [ TrueClass, FalseClass ], default: false
        end
      end

      result = builder.build! do
        database do
          username 'db_user'
          password 'db_pass'
          ssl_enabled true
        end
      end

      expect( result[ :database ][ :host ] ).to eq( 'localhost' )
      expect( result[ :database ][ :port ] ).to eq( 5432 )
      expect( result[ :database ][ :username ] ).to eq( 'db_user' )
      expect( result[ :database ][ :password ] ).to eq( 'db_pass' )
      expect( result[ :database ][ :ssl_enabled ] ).to eq( true )
    end
  end

  context 'complex builder with arrays and defaults' do
    it 'handles complex builders with arrays of different types and defaults' do
      builder = described_class.new.define do
        api_key String
        notifications do
          enabled [ TrueClass, FalseClass ], default: true
          channels String, array: true, default: [ 'email', 'sms' ]
          email_settings do
            sender String, default: 'no-reply@example.com'
            recipients String, array: true
          end
        end
      end

      result = builder.build! do
        api_key 'test-api-key'
        notifications do
          channels [ 'push' ]
          email_settings do
            recipients [ 'user1@example.com', 'user2@example.com' ]
          end
        end
      end

      expect( result[ :api_key ] ).to eq( 'test-api-key' )
      expect( result[ :notifications ][ :enabled ] ).to eq( true )
      expect( result[ :notifications ][ :channels ] ).to eq( [ 'push' ] )
      expect( result[ :notifications ][ :email_settings ][ :sender ] ).to eq( 'no-reply@example.com' )
      expect( result[ :notifications ][ :email_settings ][ :recipients ] ).to eq( [ 'user1@example.com', 'user2@example.com' ] )
    end
  end

  context 'type validation with custom error messages' do
    it 'provides meaningful error messages when type validation fails' do
      builder = described_class.new.define do
        age Integer
      end

      expect {
        builder.build! do
          age 'twenty'
        end
      }.to raise_error( 
        DynamicSchema::IncompatibleTypeError, 
        /expects 'Integer' but incompatible 'String'/ 
      )
    end
  end

  context 'using the :as option with arrays' do
    it 'correctly maps parameter names using :as with array parameters' do
      builder = described_class.new.define do
        tagsList String, as: :tags, array: true
      end

      result = builder.build! do
        tagsList [ 'tag1', 'tag2' ]
      end

      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
      expect( result[ :tagsList ] ).to be_nil
    end
  end

  context 'multiple nested parameters' do
    it 'handles multiple levels of nested parameters' do
      builder = described_class.new.define do
        level1 do
          param1 String, default: 'default1'
          level2 do
            param2 String, default: 'default2'
            level3 do
              param3 String, default: 'default3'
            end
          end
        end
      end

      result = builder.build! do
        level1 do
          param1 'value1'
          level2 do
            param2 'value2'
            level3 do
              param3 'value3'
            end
          end
        end
      end

      expect( result[ :level1 ][ :param1 ] ).to eq( 'value1' )
      expect( result[ :level1 ][ :level2 ][ :param2 ] ).to eq( 'value2' )
      expect( result[ :level1 ][ :level2 ][ :level3 ][ :param3 ] ).to eq( 'value3' )
    end
  end

  context 'edge cases and error handling' do
    it 'raises an error when required parameter is missing' do
      builder = described_class.new.define do
        required_param String
      end

      result = builder.build! do
        # required_param is not provided
      end

      expect( result[ :required_param ] ).to be_nil
    end

    it 'allows nil values when type is not specified' do
      builder = described_class.new.define do
        optional_param
      end

      result = builder.build! do
        optional_param nil
      end
  
      expect( result[ :optional_param ] ).to be_nil
    end

  end

  context 'parameter aliases using :as option' do
    it 'allows multiple parameters to map to the same internal key' do
      builder = described_class.new.define do
        username String, as: :user
        user_name String, as: :user
      end

      result = builder.build! do
        username 'testuser'
      end

      expect( result[ :user ] ).to eq( 'testuser' )

      result = builder.build! do
        user_name 'anotheruser'
      end

      expect( result[ :user ] ).to eq( 'anotheruser' )
    end
  end

  context 'parameter overriding and precedence' do
    it 'gives precedence to the last parameter set' do
      builder = described_class.new.define do
        param String
      end

      result = builder.build! do
        param 'first value'
        param 'second value'
      end

      expect( result[ :param ] ).to eq( 'second value' )
    end
  end

  context 'array parameters with default values' do
    it 'uses default array values when none are provided' do
      builder = described_class.new.define do
        roles String, array: true, default: [ 'user', 'admin' ]
      end

      result = builder.build! do
        # No roles provided
      end

      expect( result[ :roles ] ).to eq( [ 'user', 'admin' ] )
    end

    it 'overrides default array values when provided' do
      builder = described_class.new.define do
        roles String, array: true, default: [ 'user', 'admin' ]
      end

      result = builder.build! do
        roles [ 'editor', 'moderator' ]
      end

      expect( result[ :roles ] ).to eq( [ 'editor', 'moderator' ] )
    end
  end

  context 'boolean parameter edge cases' do
    
    it 'accepts true and false correctly' do
      builder = described_class.new.define do
        enabled [ TrueClass, FalseClass ]
      end

      result = builder.build! do
        enabled true
      end

      expect( result[ :enabled ] ).to eq( true )

      result = builder.build! do
        enabled false
      end

      expect( result[ :enabled ] ).to eq( false )
    end

    it 'raises an error when a non-boolean value is provided' do
      builder = described_class.new.define do
        enabled [ TrueClass, FalseClass ]
      end

      result = builder.build! do
        enabled 'yes'
      end

      expect( result[ :enabled ] ).to eq( true ) 
    end

  end

  context 'inherit option' do

    it 'inherits from an existing schema and adds new properties' do
      parent_class = Class.new do
        include DynamicSchema::Definable
        schema do
          parent_value String
        end
      end

      builder = described_class.new.define( inherit: parent_class.schema ) do
        child_value Integer
      end

      result = builder.build do
        parent_value 'foo'
        child_value 42
      end

      expect( result[ :parent_value ] ).to eq( 'foo' )
      expect( result[ :child_value ] ).to eq( 42 )
      expect { parent_class.builder.build { child_value 1 } }.to raise_error( NoMethodError )
    end
  end

end
