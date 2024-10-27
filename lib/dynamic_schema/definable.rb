module DynamicSchema 
  module Definable 

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods

      def schema( &block )
        @_schema ||= [] 
        if block_given? 
          # note that the memoized builder is reset when schema is called with a new block so 
          # that additions to the schema are incorporated into future builder ( but this does
          # not work if the schema is updated on a superclass after this class' builder has 
          # been returned )
          @_builder = nil 
          @_schema << block 
        end
        schema_blocks = _collect_schema
        proc do
          schema_blocks.each do | block |
            instance_eval( &block )
          end
        end
      end

      def builder 
        @_builder ||= DynamicSchema.define( &schema )
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

