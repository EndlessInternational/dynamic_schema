# spec/dynamic_schema/builder_from_spec.rb
require 'spec_helper'
require 'tempfile'

RSpec.describe DynamicSchema::Builder do

  describe 'building from external DSL source' do
    let( :builder ) do
      # very small schema to keep things focused on the from_* methods
      described_class.new.define do
        username    String
        roles       String, array: true, default: [ 'user' ]
      end
    end

    it 'builds from file contents' do
      Tempfile.create( [ 'dsl', '.rb' ] ) do | file |
        file.write <<~RUBY
          username 'alice'
          roles [ 'admin', 'editor' ]
        RUBY
        file.flush

        result = builder.build_from_file( file.path )

        expect( result[ :username ] ).to eq( 'alice' )
        expect( result[ :roles ] ).to eq( [ 'admin', 'editor' ] )
      end
    end

    it 'builds from in-memory source (bytes/string)' do
      source = <<~RUBY
        username 'bob'
        # roles omitted → picks default
      RUBY

      result = builder.build_from_bytes( source, filename: '(spec)' )

      expect( result[ :username ] ).to eq( 'bob' )
      expect( result[ :roles ] ).to eq( [ 'user' ] )
    end

    it 'build! with a block applies values and calls validate!' do
      allow( builder ).to receive( :validate! ).and_return( true )

      result = builder.build! do
        username 'carol'
        roles [ 'staff' ]
      end

      expect( result[ :username ] ).to eq( 'carol' )
      expect( result[ :roles ] ).to eq( [ 'staff' ] )
      expect( builder ).to have_received( :validate! ).with( a_hash_including( username: 'carol' ) )
    end

    it 'build_from_file! delegates to validate!' do
      allow( builder ).to receive( :validate! ).and_return( true )

      Tempfile.create( [ 'dsl', '.rb' ] ) do | file |
        file.write <<~RUBY
          username 'dave'
          roles [ 'moderator' ]
        RUBY
        file.flush

        result = builder.build_from_file!( file.path )

        expect( result[ :username ] ).to eq( 'dave' )
        expect( result[ :roles ] ).to eq( [ 'moderator' ] )
        expect( builder ).to have_received( :validate! ).with( a_hash_including( username: 'dave' ) )
      end
    end
  end
end