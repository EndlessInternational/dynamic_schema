module DynamicSchema 
  module Buildable

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods

      def build( attributes = nil, &block )
        new( builder.build( attributes, &block ) )
      end 

      def build!( attributes = nil, &block )
        new( builder.build!( attributes, &block ) )
      end 

    end 

  end
end

