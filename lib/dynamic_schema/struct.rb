module DynamicSchema
  class Struct

    # included into all generated struct classes
    module Class; end

    class << self

      def define( inherit: nil, &block )
        builder = ::DynamicSchema.define( inherit: inherit, &block )
        new( builder.schema )
      end

      def new( schema, &block )
        __compiled_schema = __compile_schema( schema )

        klass = ::Class.new do
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
            @attributes = attributes ? attributes.dup : {}
          end

          def to_h
            @attributes.dup
          end

          def validate!
           ::DynamicSchema::Validator.validate!( to_h, schema: compiled_schema )
            self
          end

          def validate
           ::DynamicSchema::Validator.validate( to_h, schema: compiled_schema )
          end

          def valid?
           ::DynamicSchema::Validator.valid?( to_h, schema: compiled_schema )
          end

          # Define readers/writers from the compiled schema
          __compiled_schema.each do | key, criteria |
            property_name = ( criteria[ :as ] || key ).to_sym
            type = criteria[ :type ]
            if type == ::Object
              define_method( property_name ) do
                value = @attributes[ property_name ]
                schema = criteria[ :schema ] ||= ( criteria[ :compiler ]&.compiled )
                return value unless schema
                klass = criteria[ :class ] || ::DynamicSchema::Struct.new( schema )
                if criteria[ :array ]
                  Array( value ).map { | v | klass.build( v || {} ) }
                else
                  klass.build( value || {} )
                end
              end
            elsif type
              define_method( property_name ) do 
                value = @attributes[ property_name ]
                if criteria[ :array ]
                  Array( value ).map do | v |
                    ::DynamicSchema::Converter.convert( v, to: type ) do | v | 
                      type.new( v ) || v rescue v
                    end
                  end
                else 
                  ::DynamicSchema::Converter.convert( value, to: type ) do | v | 
                    type.new( v ) || v rescue v
                  end
                end
              end
            else
              define_method( property_name ) { @attributes[ property_name ] } 
            end

            define_method( :"#{ property_name }=" ) { | value | @attributes[ property_name ] = value }
          end

        private

          def compiled_schema
            self.class.compiled_schema
          end

        end

        klass.include( ::DynamicSchema::Struct::Class )

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
