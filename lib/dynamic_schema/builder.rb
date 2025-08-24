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
      self.schema = Resolver.new( self.schema ).resolve( &block )._schema 
      self
    end 

    def build( values = nil, &block )
      receiver = Receiver.new( values, schema: self.schema, converters: self.converters )
      receiver.instance_eval( &block ) if block
      receiver.to_h 
    end

    def build_from_bytes( bytes, filename: '(schema)', values: nil )
      receiver = Receiver.new( values, schema: schema, converters: converters )
      receiver.instance_eval( bytes, filename, 1 )
      receiver.to_h
    end

    def build_from_file( path, values: nil )
      self.build_from_bytes( File.read( path, encoding: 'UTF-8' ), filename: path, values: values )
    end

    [ :build, :build_from_source, :build_from_file ].each do |name|
      define_method( :"#{name}!" ) do |*args, **kwargs, &blk|
        result = public_send(name, *args, **kwargs, &blk)
        validate!(result)
        result
      end
    end

  private 
    attr_accessor :schema

  end
end
