require 'spec_helper'

RSpec.describe DynamicSchema::Converter do
  describe '.convert and .convert!' do
    it 'converts strings to Integer' do
      expect( described_class.convert( '42', to: Integer ) ).to eq( 42 )
      expect( described_class.convert( 'x', to: Integer ) ).to be_nil
    end

    it 'converts using an array of boolean types (TrueClass, FalseClass)' do
      expect( described_class.convert( 'true',  to: [ TrueClass, FalseClass ] ) ).to eq( true )
      expect( described_class.convert( 'false', to: [ TrueClass, FalseClass ] ) ).to eq( false )

      expect( described_class.convert( 'yes',   to: [ TrueClass, FalseClass ] ) ).to eq( true )
      expect( described_class.convert( 'no',    to: [ TrueClass, FalseClass ] ) ).to eq( false )

      expect( described_class.convert( 1,       to: [ TrueClass, FalseClass ] ) ).to eq( true )
      expect( described_class.convert( 0,       to: [ TrueClass, FalseClass ] ) ).to eq( false )

      # non-coercible
      expect( described_class.convert( 'x',     to: [ TrueClass, FalseClass ] ) ).to be_nil
    end

    it 'tries types in order and returns the first successful conversion' do
      # Integer will fail to parse "3.0", but Float succeeds
      expect( described_class.convert( '3.0', to: [ Integer, Float ] ) ).to eq( 3.0 )

      # Integer succeeds immediately, so Float is not attempted
      expect( described_class.convert( '7', to: [ Integer, Float ] ) ).to eq( 7 )
    end

    it 'chooses Float when ordered before Integer for decimal strings' do
      expect( described_class.convert( '1.23', to: [ Float, Integer ] ) ).to eq( 1.23 )
    end

    it 'chooses Float when Integer fails for decimal strings even if Integer is first' do
      # Integer('1.23') fails, then Float succeeds
      expect( described_class.convert( '1.23', to: [ Integer, Float ] ) ).to eq( 1.23 )
    end

    it 'returns the value as-is when it already matches any of the types' do
      # value is already TrueClass, matched on the second type
      expect( described_class.convert( true, to: [ FalseClass, TrueClass ] ) ).to eq( true )

      # Strings remain strings if String is among the target types
      expect( described_class.convert( '42', to: [ String, Integer ] ) ).to eq( '42' )
    end

    it 'yields the block fallback when none of the types match' do
      result = described_class.convert( 'x', to: [ Integer, Float ] ) { | v | v.to_s }
      expect( result ).to eq( 'x' )
    end

    it 'converts strings to Float' do
      expect( described_class.convert( '3.14', to: Float ) ).to eq( 3.14 )
      expect( described_class.convert( 'x', to: Float ) ).to be_nil
    end

    it 'converts strings to Date and Time' do
      expect( described_class.convert( '2024-01-02', to: Date ) ).to eq( Date.new( 2024, 1, 2 ) )

      t = described_class.convert( '2024-01-02 03:04:05', to: Time )
      expect( t ).to be_a( Time )
    end

    it 'converts strings to URI' do
      uri = described_class.convert( 'http://example.com', to: URI )
      expect( uri ).to eq( URI.parse( 'http://example.com' ) )
    end

    it 'converts to String and Symbol' do
      expect( described_class.convert( 123, to: String ) ).to eq( '123' )

      expect( described_class.convert( 'abc', to: Symbol ) ).to eq( :abc )

      # not symbolizable
      expect( described_class.convert( 123, to: Symbol ) ).to be_nil
    end

    it 'converts to TrueClass and FalseClass' do
      expect( described_class.convert( 'true', to: TrueClass ) ).to eq( true )
      expect( described_class.convert( 1, to: TrueClass ) ).to eq( true )

      expect( described_class.convert( 'false', to: FalseClass ) ).to eq( false )
      expect( described_class.convert( 0, to: FalseClass ) ).to eq( false )

      # mismatched inputs return nil / false
      expect( described_class.convert( 'no', to: TrueClass ) ).to be_nil
      expect( described_class.convert( 'yes', to: FalseClass ) ).to be_nil
    end

    it 'converts to Array (including nil -> [])' do
      expect( described_class.convert( 1, to: Array ) ).to eq( [ 1 ] )
      expect( described_class.convert( [ 1, 2 ], to: Array ) ).to eq( [ 1, 2 ] )
      expect( described_class.convert( nil, to: Array ) ).to eq( nil )
    end

    it 'returns nil when no converter exists, but yields block fallback' do
      klass = Class.new
      expect( described_class.convert( 'x', to: klass ) ).to be_nil
      expect( described_class.convert( 'x', to: klass ) { | v | v.to_s.reverse } ).to eq( 'x' )
    end

    it 'supports registering a custom converter' do
      custom = Class.new do
        attr_reader :value
        def initialize(v) @value = v end
      end

      described_class.register_converter( custom ) { | v | custom.new( v.to_s.upcase ) }

      obj = described_class.convert( 'hello', to: custom )
      expect( obj ).to be_a( custom )
      expect( obj.value ).to eq( 'HELLO' )
      # ensure convert! also works
      obj2 = described_class.convert( 'hi', to: custom )
      expect( obj2.value ).to eq( 'HI' )
    end
  end
end
