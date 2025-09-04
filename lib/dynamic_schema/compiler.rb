require_relative 'receiver/object'

module DynamicSchema
  class Compiler < BasicObject
    
    def initialize( compiled_schema = nil, compiled_blocks: nil )
      @compiled_schema = compiled_schema || {}
      
      @block = nil 
      @compiled = false 
      @compiled_blocks = compiled_blocks || []
    end

    def compile( &block )
      @block = block 
      @compiled = false 
      unless @compiled_blocks.include?( @block )
        @compiled_blocks << @block
        self.instance_eval( &@block )
        @compiled = true 
      end
      self
    end
        
    def compiled 
      if !@compiled && @block 
        @compiled_blocks << @block unless @compiled_blocks.include?( @block )
        self.instance_eval( &@block ) 
        @compiled = true
      end
      @compiled_schema 
    end

    def _value( name, options )
      name = name.to_sym
      receiver = ::DynamicSchema::Receiver::Object
      ::Kernel.raise ::NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if receiver.method_defined?( name ) || receiver.private_method_defined?( name )
  
      _validate_in!( name, options[ :type ], options[ :in ] ) if options[ :in ] 
      
      @compiled_schema[ name ] = options
      self
    end

    def _object( name, options = {}, &block )
      name = name.to_sym
      receiver = ::DynamicSchema::Receiver::Object
      ::Kernel.raise ::NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if receiver.method_defined?( name ) || receiver.private_method_defined?( name )

      @compiled_schema[ name ] = options.merge( {
        type: ::Object,
        compiler: Compiler.new( compiled_blocks: @compiled_blocks ).compile( &block )
      } )    
      self
    end

    def method_missing( method, *args, &block )
      first = args.first
      options = nil
      if args.empty?
        options = {}
      elsif first.is_a?( ::Hash )
        options = first 
      elsif args.length == 1 && 
            ( first.is_a?( ::Class ) || first.is_a?( ::Module ) || first.is_a?( ::Array ) )
        options = { type: first }
      elsif args.length == 2 && 
            ( first.is_a?( ::Class ) || first.is_a?( ::Module ) || first.is_a?( ::Array ) ) && 
            args[ 1 ].is_a?( ::Hash )
        options = args[ 1 ]
        options[ :type ] = args[ 0 ]
      else
        ::Kernel.raise \
          ::ArgumentError, 
          "A schema definition may only include the type (Class or Module) followed by options (Hash). "
      end

      type = options[ :type ]
      if type == ::Object || ( type.nil? && block )
        _object( method, options, &block )
      else
        _value( method, options )
      end
    
    end

    def to_s
      inspect
    end

    def inspect
      { schema: @compiled_schema }.inspect 
    end

    def class
      ::DynamicSchema::Compiler
    end

    def is_a?( klass )
      klass == ::DynamicSchema::Compiler || klass == ::BasicObject
    end

    alias :kind_of? :is_a?

    if defined?( ::PP )
      include ::PP::ObjectMixin 
      def pretty_print( pp )
        pp.pp( { schema: @compiled_schema } )
      end
    end      
  
  private

    def _validate_in!( name, type, in_option )
      ::Kernel.raise ::TypeError,
            "The parameter '#{name}' includes the :in option but it does not respond to 'include?'." \
        unless in_option.respond_to?( :include? )
    end

  end
end
