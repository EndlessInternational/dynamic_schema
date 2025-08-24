module DynamicSchema 
  module Buildable

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods
      [ :build, :build_from_bytes, :build_from_file ].each do | name |
        define_method( name ) do | *args, **kwargs, &block |
          new( builder.public_send( name, *args, **kwargs, &block ) )
        end

        define_method( :"#{name}!" ) do | *args, **kwargs, &block |
          new( builder.public_send( :"#{name}!", *args, **kwargs, &block ) )
        end
      end
    end 

  end
end

