module DynamicSchema
  class Struct
    include Validator
    class << self

      def define( inherit: nil, &block )
        builder = ::DynamicSchema.define( inherit: inherit, &block )
        new( builder.schema )
      end
     
      def new( *arguments, &block )
        unless self == ::DynamicSchema::Struct
          super
        else
          __schema = arguments.first  
          ::Kernel.raise ::ArgumentError, "A Struct requires a schema." \
            unless __schema 
          __converter = ::DynamicSchema::Converter

          __compiled_schema = __compile_schema( __schema )
          __klass = ::Class.new( self ) do
            
            class << self
              def build( attributes = {}, &block )
                struct = new( attributes )
                block.call( struct ) if block
                struct
              end

              def build!( attributes = {}, &block )
                struct = build( attributes, &block )
                struct.validate!
                struct
              end
            end

            def initialize( attributes = nil )
              @attributes = attributes&.dup || {}
              @converted_attributes = {}
            end

            __compiled_schema.each do | property, criteria |
              
              key = ( criteria[ :as ] || property ).to_sym
              type = criteria[ :type ]
              default = criteria[ :default ]

              if type == ::Object
                define_method( property ) do
                  @converted_attributes.fetch( key ) do
                    value = @attributes[ key ]
                    schema = criteria[ :schema ] ||= ( criteria[ :compiler ]&.compiled )
                    return value unless schema
                    klass = criteria[ :class ] ||= ::DynamicSchema::Struct.new( schema )
                    @converted_attributes[ key ] = 
                      if criteria[ :array ]
                        Array( value || default ).map { | v | klass.build( v || {} ) }
                      else
                        klass.build( value || default )
                      end
                  end
                end
              elsif type
                define_method( property ) do 
                  @converted_attributes.fetch( key ) do 
                    value = @attributes[ key ] 
                    @converted_attributes[ key ] = criteria[ :array ] ? 
                      Array( value || default ).map { | v | __convert( v, to: type ) } : 
                      __convert( value || default, to: type )
                  end
                end
              else
                define_method( property ) do
                  @attributes[ key ] || default
                end 
              end

              define_method( :"#{ property }=" ) do | value | 
                @converted_attributes.delete( key )
                @attributes[ key ] = value 
              end

            end
          
            [ :validate!, :validate, :valid? ].each do | method |
              define_method( method ) { super( @attributes ) }
            end

            def to_h
              result = {}
              self.compiled_schema.each do | property, criteria |
                key = criteria[ :as ] || property
                value = __object_to_h( self.send( property ) ) 
                result[ key ] = value unless value.nil?
              end
              result
            end

          private 

            def compiled_schema
              self.class.compiled_schema
            end

            def __object_to_h( object )
              case object
              when nil
                nil
              when ::Hash
                object.transform_values { | v | __object_to_h( v ) } unless object.empty?
              when ::Array
                object.map { | e | __object_to_h( e ) } unless object.empty?
              else
                if object.respond_to?( :to_h )
                  __object_to_h( object.to_h )
                else
                  object
                end
              end
            end

            def __convert( value, to: )
              self.class.converter.convert( value, to: to ) { | v | to.new( v ) rescue nil }
            end

          end
          __klass.instance_variable_set( :@__compiled_schema, __compiled_schema.dup )
          __klass.instance_variable_set( :@__converter, __converter )
          __klass.class_eval( &block ) if block
          __klass
        end
      end

      def compiled_schema
        @__compiled_schema || 
          ( superclass.respond_to?( :compiled_schema ) && superclass.compiled_schema )
      end

      def converter
        @__converter || ( superclass.respond_to?( :converter ) && superclass.converter )
      end

    private 

      def __compile_schema( schema )
        case schema
        when ::Proc
          compiler = ::DynamicSchema::Compiler.new
          compiler.compile( &schema )
          compiler.compiled
        when ::Hash
          ::Kernel.raise ::ArgumentError,
                         "A Struct requires a schema but an empty Hash was given." \
            if schema.empty?
          schema
        else
          if schema.respond_to?( :compiled_schema, true )
            schema.send( :compiled_schema )
          else
            ::Kernel.raise ::ArgumentError,
                           "A Struct requires a schema. I must be a Builder, Proc, or Hash."
          end
        end
      end
    end
  end
end
