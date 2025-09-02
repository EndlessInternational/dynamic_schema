require_relative 'builder_methods/conversion'
require_relative 'validator'
require_relative 'compiler'
require_relative 'receiver/object'

module DynamicSchema
  class Builder 

    include BuilderMethods::Conversion 
    include Validator
  
    def initialize
      self.compiled_schema = nil 
      @schema_blocks = []
      super()
    end

    def define( inherit: nil, &block )
      @schema_blocks << inherit if inherit
      @schema_blocks << block if block

      compiler = Compiler.new( self.compiled_schema )
      compiler.compile( &inherit ) if inherit
      compiler.compile( &block ) if block
      self.compiled_schema = compiler.compiled
      self
    end 

    def schema
      blocks = @schema_blocks.dup
      proc do 
        blocks.each { | block | instance_eval( &block ) }
      end
    end

    def build( values = nil, &block )
      receiver = Receiver::Object.new( 
        values, 
        schema: self.compiled_schema, converters: self.converters 
      )
      receiver.instance_eval( &block ) if block
      receiver.to_h 
    end

    def build_from_bytes( bytes, filename: '(schema)', values: nil )
      receiver = Receiver::Object.new( 
        values, 
        schema: compiled_schema, converters: converters 
      )
      receiver.instance_eval( bytes, filename, 1 )
      receiver.to_h
    end

    def build_from_file( path, values: nil )
      self.build_from_bytes( 
        File.read( path, encoding: 'UTF-8' ), 
        filename: path, values: values 
      )
    end

    [ :build, :build_from_bytes, :build_from_file ].each do |name|
      define_method( :"#{name}!" ) do |*args, **kwargs, &blk|
        result = public_send(name, *args, **kwargs, &blk)
        validate!(result)
        result
      end
    end

  private 
    attr_accessor :compiled_schema

  end
end
