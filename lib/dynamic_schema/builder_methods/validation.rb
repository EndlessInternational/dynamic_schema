module DynamicSchema
  module BuilderMethods
    module Validation

      def validate!( values, schema: self.schema )
        traverse_and_validate_values( values, schema: schema ) { | error | 
          raise error 
        } 
      end
    
      def validate( values, schema: self.schema )
        errors = []
          traverse_and_validate_values( values, schema: schema ) { | error | 
            errors << error 
        }
        errors
      end

      def valid?( values, schema: self.schema )
        traverse_and_validate_values( values, schema: schema ) { 
          return false 
        }
        return true
      end

    protected

      def value_matches_types?( value, types )
        type_match = false  
        Array( types ).each do | type |
          type_match = value.is_a?( type )
          break if type_match
        end
        type_match
      end 

      def traverse_and_validate_values( values, schema:, path: nil, options: nil, &block )  
        path.chomp( '/' ) if path
        unless values.is_a?( Hash )
          raise ArgumentError, "The values must always be a Hash." 
        end

        schema.each do | key, criteria |

          name = criteria[ :as ] || key 
          value = values[ name ]

          if criteria[ :required ] && 
             ( !value || ( value.respond_to?( :empty ) && value.empty? ) )
            block.call( RequiredOptionError.new( path: path, key: key ) )
          elsif criteria[ :in ] 
            Array( value ).each do | v |
              unless criteria[ :in ].include?( v ) || v.nil?
                block.call( 
                  InOptionError.new( path: path, key: key, option: criteria[ :in ], value: v )
                )
              end
            end
          elsif !criteria[ :default_assigned ] && !value.nil?
            unless criteria[ :array ]
              if criteria[ :type ] == Object
                traverse_and_validate_values( 
                  values[ name ],
                  schema: criteria[ :schema ] ||= criteria[ :resolver ]._schema,
                  path: "#{ ( path || '' ) + ( path ? '/' : '' ) + key.to_s }", 
                  &block 
                )
              else     
                if criteria[ :type ] && value && !criteria[ :default_assigned ]
                  unless value_matches_types?( value, criteria[ :type ] )
                    block.call( IncompatibleTypeError.new( 
                      path: path, key: key, type: criteria[ :type ], value: value
                    ) )
                  end          
                end
              end
            else 
              if criteria[ :type ] == Object
                groups = Array( value )
                groups.each do | group |
                  traverse_and_validate_values(
                    group, 
                    schema: criteria[ :schema ] ||= criteria[ :resolver ]._schema,
                    path: "#{ ( path || '' ) + ( path ? '/' : '' ) + key.to_s }", 
                    &block 
                  )
                end
              else
                if criteria[ :type ] && !criteria[ :default_assigned ]
                  value_array = Array( value )
                  value_array.each do | v | 
                    unless value_matches_types?( v, criteria[ :type ] )
                      block.call( IncompatibleTypeError.new( 
                        path: path, key: key, type: criteria[ :type ], value: v
                      ) )
                    end
                  end  
                end
              end
            end
          end

        end
        nil
      end

    end
  end
end
