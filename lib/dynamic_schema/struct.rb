module DynamicSchema
  class Struct

    # base class for all generated struct classes
    class Class; end

    class << self

      def define( inherit: nil, &block )
        builder = ::DynamicSchema.define( inherit: inherit, &block )
        new( builder.schema )
      end

      def new( schema, &block )
        __compiled_schema = __compile_schema( schema )

        klass = ::Class.new( ::DynamicSchema::Struct::Class ) do
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

            attr_reader :compiled_schema
          end

          def initialize( attributes = nil )
            @attributes = attributes&.dup || {}
            @coerced_attributes = {}
          end

          def []( key )
            @coerced_attributes[ key ] || @attributes[ key ]
          end

          def to_h
            result = {}
            compiled_schema.each do | key, criteria |
              property_name = ( criteria[ :as ] || key ).to_sym
              value = __object_to_h( self.send( property_name ) ) 
              result[ property_name ] = value if value
            end
            result
          end

          def validate!
           ::DynamicSchema::Validator.validate!( @attributes, schema: compiled_schema )
            self
          end

          def validate
           ::DynamicSchema::Validator.validate( @attributes, schema: compiled_schema )
          end

          def valid?
           ::DynamicSchema::Validator.valid?( @attributes, schema: compiled_schema )
          end

          __compiled_schema.each do | key, criteria |
            property_name = ( criteria[ :as ] || key ).to_sym
            type = criteria[ :type ]
            if type == ::Object
              define_method( property_name ) do
                @coerced_attributes.fetch( property_name ) do
                  value = @attributes[ property_name ]
                  schema = criteria[ :schema ] ||= ( criteria[ :compiler ]&.compiled )
                  return value unless schema
                  klass = criteria[ :class ] || ::DynamicSchema::Struct.new( schema )
                  @coerced_attributes[ property_name ] = 
                    if criteria[ :array ]
                      Array( value ).map { | v | klass.build( v || {} ) }
                    else
                      klass.build( value || {} )
                    end
                end
              end
            elsif type
              define_method( property_name ) do 
                @coerced_attributes.fetch( property_name ) do 
                  value = @attributes[ property_name ]
                  @coerced_attributes[ property_name ] = criteria[ :array ] ? 
                    Array( value ).map { | v | __coerce( v, to: type ) } : 
                    __coerce( value, to: type )
                end
              end
            else
              define_method( property_name ) do 
                @attributes[ property_name ]
              end 
            end

            define_method( :"#{ property_name }=" ) do | value | 
              @coerced_attributes.delete( property_name )
              @attributes[ property_name ] = value 
            end
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

          def __coerce( value, to: )
            if value.nil? || value.is_a?( to ) 
              value
            else
              ::DynamicSchema::Converter.convert( value, to: to ) do | v | 
                to.new( v ) || v rescue v 
              end
            end 
          end

        end

        # klass.include( ::DynamicSchema::Struct::Class )

        klass.instance_variable_set( :@compiled_schema, __compiled_schema )
        klass.class_eval( &block ) if block
        klass
      end

    private

      def __compile_schema( schema )
        case schema
        when ::Proc
          compiler = ::DynamicSchema::Compiler.new
          compiler.compile( &schema )
          compiler.compiled
        when ::Hash
          schema
        else
          if schema.respond_to?( :compiled_schema, true )
            schema.send( :compiled_schema )
          else
            ::Kernel.raise ::ArgumentError,
                           "A Struct requires a schema through a Builder, Proc, or Hash."
          end
        end
      end

    end
  end
end
