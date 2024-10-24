require_relative 'builder_methods/conversion'
require_relative 'builder_methods/validation'
require_relative 'resolver'
require_relative 'receiver'

module DynamicSchema
  class Builder 

    include BuilderMethods::Validation 
    include BuilderMethods::Conversion 
  
    def initialize( schema = nil )
      self.schema = schema 
      super()
    end

    def define( &block )
      self.schema = Resolver.new( self.schema ).resolve( &block ).schema 
      self
    end 

    def build( values = nil, &block )
      receiver = Receiver.new( values, schema: self.schema, converters: self.converters )
      receiver.instance_eval( &block ) if block
      receiver.to_h 
    end

    def build!( values = nil, &block )
      result = self.build( values, &block )
      validate!( result )
      result 
    end

  private 
    attr_accessor :schema

  end
end
