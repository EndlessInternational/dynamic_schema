module DynamicSchema 
  module Definable 

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods

      def schema( &block )
        @_schema ||= []
        @_schema << block if block_given?
        schema_blocks = _collect_schema
        proc do
          schema_blocks.each do | block |
            instance_eval( &block )
          end
        end
      end

    protected 

      def _collect_schema
        schema_blocks = []
        if superclass.singleton_methods.include?( :_collect_schema )
          schema_blocks.concat( superclass._collect_schema )
        end
        schema_blocks.concat( @_schema ) if defined?( @_schema )
        schema_blocks
      end

    end 

  end
end

