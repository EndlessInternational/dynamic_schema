require_relative 'builder'

module DynamicSchema
	module Definition

    def schema( schema = {}, &block )
      @_schema_builder ||= DynamicSchema::Builder.new( schema ).define( &block )
    end

    def build_with_schema( attributes = nil, &block )
      raise RuntimeError, "The schema has not been defined." if @_schema_builder.nil?
      @_schema_builder.build( attributes, &block )
    end
    
    def build_with_schema!( attributes = nil, &block )
      raise RuntimeError, "The schema has not been defined." if @_schema_builder.nil?
      @_schema_builder.build!( attributes, &block )
    end

  end
end

