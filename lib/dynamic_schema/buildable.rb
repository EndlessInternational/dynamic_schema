module DynamicSchema 
  module Buildable

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods

      def build( attributes = nil, &block )
        @_builder ||= Builder.new.define( &self.schema )
        new( @_builder.build( attributes, &block ) )
      end 

      def build!( attributes = nil, &block )
        @_builder ||= Builder.new.define( &self.schema )
        new( @_builder.build!( attributes, &block ) )
      end 

    end 

  end
end

