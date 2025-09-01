# Intentionally no requires here to avoid circular dependencies.

module DynamicSchema 
  module Receiver
    class Base < BasicObject

      def self.const_missing( name )
        ::Object.const_get( name )
      end

      if defined?( ::PP )
        include ::PP::ObjectMixin
        def pretty_print( pp )
          pp.pp( { values: @values, schema: @schema } )
        end
      end


      def evaluate( &block )
        self.instance_eval( &block )
        self
      end

      def nil?
        false  
      end

      def to_s
        inspect
      end

      def inspect
        { values: @values, schema: @schema }.inspect 
      end

    private

      if defined?( ::PP )
        def pp( *args )
          ::PP.pp( *args )
        end
      end

      %i[ String Integer Float Array Hash Symbol Rational Complex
          raise require puts warn p ].each do | method |
        define_method( method ) { | *args, &block | ::Kernel.public_send( method, *args, &block ) }
      end      

      def fail( *args ) = ::Kernel.raise( *args )

      def require_relative( path )
        location = ::Kernel.caller_locations( 1, 1 ).first
        base_dir = location&.absolute_path ? ::File.dirname( location.absolute_path ) : ::File.dirname( location.path )
        absolute = ::File.expand_path( path, base_dir )
        ::Kernel.require( absolute )
      end

    end
  end
end    
