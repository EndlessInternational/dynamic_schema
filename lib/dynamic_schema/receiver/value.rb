require_relative 'base'

module DynamicSchema
  module Receiver
    class Value < Base
      def initialize( target )
        @target = target
      end

      def method_missing( method_name, *args, &block )
        writer_method = :"#{ method_name }="
        unless @target.respond_to?( writer_method )
          ::Kernel.raise ::NoMethodError,
            "The attribute '#{ method_name }' cannot be assigned because '#{ @target.class.name }' does not define '#{ writer_method }'."
        end

        if args.length != 1
          ::Kernel.raise ::ArgumentError,
            "The attribute '#{ method_name }' requires 1 argument but #{ args.length } was given."
        end

        @target.public_send( writer_method, args.first )
      end
    end
  end
end

