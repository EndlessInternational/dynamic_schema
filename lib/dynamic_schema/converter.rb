# types must be included to support coersion
require 'time'
require 'date'
require 'uri'

module DynamicSchema 
  module Converter 
    extend self

    def register_converter( klass, &block )
      self.converters[ klass ] = block 
    end

    def convert( value, to:, &block )
      return value if value.nil? || to.nil?

      to = Array( to )
      result = nil 

      if value.respond_to?( :is_a? )
        to.each do | type |
          result = value.is_a?( type ) ? value : nil  
          break unless result.nil?
        end
      end

      if result.nil?
        to.each do | type |
          converter = converters[ type ]
          if converter
            result = converter.call( value ) rescue nil 
            break unless result.nil?
          end
        end
      end

      result.nil? && block ? block.call( value ) : result
    end

  private

    def converters 
      @converters ||= default_converters.dup
    end
  
    def default_converters
      {  
        Array       => ->( v ) { Array( v ) },
        Date        => ->( v ) { v.respond_to?( :to_date ) ? v.to_date : Date.parse( v.to_s ) },
        Time        => ->( v ) { v.respond_to?( :to_time ) ? v.to_time : Time.parse( v.to_s ) },
        URI         => ->( v ) { URI.parse( v.to_s ) },
        String      => ->( v ) { String( v ) },
        Symbol      => ->( v ) { v.respond_to?( :to_sym ) ? v.to_sym : nil },
        Rational    => ->( v ) { Rational( v ) },
        Float       => ->( v ) { Float( v ) },
        Integer     => ->( v ) { Integer( v ) },
        TrueClass   => ->( v ) { 
          case v
          when Numeric 
            v.nonzero? ? true : nil 
          else
            v.to_s.match(  /\A\s*(true|yes)\s*\z/i ) ? true : nil 
          end
        },
        FalseClass  => ->( v ) {  
          case v
          when Numeric 
            v.zero? ? false : nil 
          else
            v.to_s.match(  /\A\s*(false|no)\s*\z/i ) ? false : nil 
          end
        }
      }.freeze
    end

  end
end
