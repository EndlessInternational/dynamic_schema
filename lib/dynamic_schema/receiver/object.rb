require_relative 'base'
require_relative 'value'

module DynamicSchema 
  module Receiver
    class Object < Base

    def initialize( values = nil, schema:, converters: )
      raise ArgumentError, 'The Receiver values must be a nil or a Hash.'\
        unless values.nil? || ( values.respond_to?( :[] ) && values.respond_to?( :key? ) )
      
      @values = {}
      @schema = schema
      @defaults_assigned = {}

      @converters = converters&.dup 
      
      @schema.each do | key, criteria |
        name = criteria[ :as ] || key 
        if criteria.key?( :default )
          self.__send__( key, criteria[ :default ] )
          @defaults_assigned[ key ] = true        
        end
        self.__send__( key, values[ key ] ) if values && values.key?( key ) 
      end

    end

    def empty?
      @values.empty?
    end

    def to_h
      recursive_to_h = ->( object ) do
        case object
        when ::NilClass
          nil
        when ::DynamicSchema::Receiver::Object
          recursive_to_h.call( object.to_h )
        when ::Hash
          object.transform_values { | value | recursive_to_h.call( value ) }
        when ::Array
          object.map { | element | recursive_to_h.call( element ) }
        else
          object.respond_to?( :to_h ) ? object.to_h : object
        end
      end

      recursive_to_h.call( @values )
    end

    def class
      ::DynamicSchema::Receiver::Object
    end

    def is_a?( klass )
      klass == ::DynamicSchema::Receiver::Object || 
      klass == ::DynamicSchema::Receiver::Base || 
      klass == ::BasicObject
    end

    alias :kind_of? :is_a?

    def method_missing( method, *args, &block )
      if @schema.key?( method )
        criteria = @schema[ method ]
        name = criteria[ :as ] || method
        value = @values[ name ]

        unless criteria[ :array ] 
          if criteria[ :type ] == ::Object 
            value = __object( method, args, value: value, criteria: criteria, &block )
          else 
            value = __value( method, args, value: value, criteria: criteria, &block )
          end
        else
          value = @defaults_assigned[ method ] ? ::Array.new : value || ::Array.new
          if criteria[ :type ] == ::Object
            value = __object_array( method, args, value: value, criteria: criteria, &block )
          else
            value = __values_array( method, args, value: value, criteria: criteria, &block )
          end
        end

        @defaults_assigned[ method ] = false
        @values[ name ] = value 
      else
        ::Kernel.raise ::NoMethodError, 
          "There is no schema value or object '#{ method }' defined in this scope which includes: " \
          "#{ @schema.keys.join( ', ' ) }." 
      end
    end

    def respond_to?( method, include_private = false )
      @schema.key?( method ) || self.class.instance_methods.include?( method ) 
    end

    def respond_to_missing?( method, include_private = false )
      @schema.key?( method ) || self.class.instance_methods.include?( method ) 
    end

  protected 
    
    def __process_arguments( name, arguments, required_arguments:  )
      count = arguments.count 
      required_arguments = [ required_arguments ].flatten if required_arguments
      required_count = required_arguments&.length || 0
      ::Kernel.raise ::ArgumentError, 
          "The attribute '#{ name }' requires #{ required_count } arguments " \
          "(#{ required_arguments.join( ', ' ) }) but #{ count } was given." \
        if count < required_count 
      ::Kernel.raise ::ArgumentError, 
          "The attribute '#{ name }' should have at most #{ required_count + 1 } arguments but " \
          "#{ count } was given." \
        if count > required_count + 1

      result = {}

      required_arguments&.each_with_index do | name, index  |
        result[ name.to_sym ] = arguments[ index ]
      end
      arguments.slice!( 0, required_arguments.length ) if required_arguments

      last = arguments.last
      case last 
      when ::Hash 
        result.merge( last )
      when ::Array 
        last.map { | v | result.merge( v ) }
      else
        result
      end
    end

    def __coerce_value( types, value )
      return value unless types && !value.nil?

      types = ::Kernel.method( :Array ).call( types ) 
      result = nil

      if value.respond_to?( :is_a? )
        types.each do | type |
          result = value.is_a?( type ) ? value : nil 
          break unless result.nil?
        end
      end

      if result.nil?
        types.each do | type |
          result = @converters[ type ].call( value ) rescue nil
          break unless result.nil?
        end
      end

      result
    end

    def __value( method, arguments, value:, criteria:, &block )
      value = arguments.first
      new_value = criteria[ :type ] ? __coerce_value( criteria[ :type ], value ) : value
      new_value = new_value.nil? ? value : new_value
      block ? 
        __value_block( method, value: new_value, criteria: criteria, &block ) : 
        new_value
    end

    def __values_array( method, arguments, value:, criteria:, &block )
      values = [ arguments.first ].flatten
      if type = criteria[ :type ]
        values = values.map do | v | 
          new_value = __coerce_value( type, v )
          new_value.nil? ? v : new_value
        end 
      end
      if block 
        values = values.map do | value | 
          __value_block( method, value: value, criteria: criteria, &block )
        end
      end
      value.concat( values )
    end 

    def __object( method, arguments, value:, criteria:, &block )
      attributes = __process_arguments( 
        method, arguments, 
        required_arguments: criteria[ :arguments ] 
      )
      if value.nil? || attributes&.any?  
        value = 
          Receiver::Object.new( 
            attributes,
            converters: @converters, 
            schema: criteria[ :schema ] ||= criteria[ :compiler ].compiled 
          )
      end
      value.instance_eval( &block ) if block
      value 
    end

    def __object_array( method, arguments, value:, criteria:, &block )
      attributes = __process_arguments( 
        method, arguments, 
        required_arguments: criteria[ :arguments ] 
      )
      value.concat( [ attributes ].flatten.map { | a |
        receiver = Receiver::Object.new( 
          a,
          converters: @converters, 
          schema: criteria[ :schema ] ||= criteria[ :compiler ].compiled 
        )
        receiver.instance_eval( &block ) if block
        receiver
      } )
    end

    def __value_block( method, value:, criteria:, &block )
      if value.nil?
        type = criteria[ :type ]
        
        if type.is_a?( ::Array )
          if type.length == 1
            type = type.first
          else
            ::Kernel.raise ::TypeError, 
                           "An explicit value for '#{method}' is required when using a block " +
                           "because multiple types were specified."
          end
        end

        case type
        when ::Class
          begin
            value = type.new
          rescue => error
            ::Kernel.raise ::TypeError, 
                           "An explicit value for '#{method}' is required because '#{type}' " + 
                           "could not be constructed: #{error.message}."
          end
        else
          ::Kernel.raise ::TypeError, 
                         "An explicit value for '#{method}' is required because '#{type}' is " +
                         "not a Class."
        end

      end
      ::DynamicSchema::Receiver::Value.new( value ).instance_eval( &block )
      value
    end

  end
  end
end    
