require_relative 'receiver'

module DynamicSchema
  class Resolver < BasicObject
    
    def initialize( schema = nil, resolved_blocks: nil )
      @schema = schema || {}
      
      @block = nil 
      @resolved = false 
      @resolved_blocks = resolved_blocks || []
    end

    def resolve( &block )
      @block = block 
      @resolved = false 
      unless @resolved_blocks.include?( @block )
        @resolved_blocks << @block
        self.instance_eval( &@block )
        @resolved = true 
      end
      self
    end
        
    def _schema 

      if !@resolved && @block 
        @resolved_blocks << @block unless @resolved_blocks.include?( @block )
        self.instance_eval( &@block ) 
        @resolved = true
      end
      @schema 
    end

    def _value( name, options )
      name = name.to_sym
      ::Kernel.raise ::NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if ::DynamicSchema::Receiver.instance_methods.include?( name )
  
      _validate_in!( name, options[ :type ], options[ :in ] ) if options[ :in ] 
      
      @schema[ name ] = options
      self
    end

    def _object( name, options = {}, &block )
      name = name.to_sym
      ::Kernel.raise ::NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if ::DynamicSchema::Receiver.instance_methods.include?( name )

      @schema[ name ] = options.merge( {
        type: ::Object,
        resolver: Resolver.new( resolved_blocks: @resolved_blocks ).resolve( &block )
      } )    
      self
    end

    def method_missing( method, *args, &block )
      first = args.first
      options = nil
      if args.empty?
        options = {}
      # when called with just options:              name as: :streams
      elsif first.is_a?( ::Hash )
        options = first 
      # when called with just type:                 name String 
      #                                             name [ TrueClass, FalseClass ] 
      elsif args.length == 1 && 
            ( first.is_a?( ::Class ) || first.is_a?( ::Module ) || first.is_a?( ::Array ) )
        options = { type: first }
      # when called with just type and options:     name String, default: 'the default'
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
      if type == ::Object || type.nil? && block 
        _object( method, options, &block )
      else 
        _value( method, options )
      end
    
    end

    def to_s
      inspect
    end

    def inspect
      { schema: @schema }.inspect 
    end

    def class
      ::DynamicSchema::Resolver
    end

    def is_a?( klass )
      klass == ::DynamicSchema::Resolver || klass == ::BasicObject
    end

    alias :kind_of? :is_a?

    if defined?( ::PP )
      include ::PP::ObjectMixin 
      def pretty_print( pp )
        pp.pp( { schema: @schema } )
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



