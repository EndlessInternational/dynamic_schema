module DynamicSchema 
  
  class Error < StandardError; end

  class IncompatibleTypeError < Error

    attr_reader :keypath 
    attr_reader :key 
    attr_reader :type

    def initialize( path: nil, key:, type:, value: )
      path = path ? path.to_s.chomp( '/' ) : nil 
      @key = key
      @keypath = path ? ( path + '/' + @key.to_s ) : @key.to_s 
      @type = type
      type_text = @type.respond_to?( :join ) ? type.join( ', ' ) : type
      super( "The attribute '#{@keypath}' expects '#{type_text}' but incompatible '#{value.class.name}' was given." )
    end

  end

  class RequiredOptionError < Error

    attr_reader :keypath 
    attr_reader :key 

    def initialize( path: nil, key:  )
      path = path ? path.chomp( '/' ) : nil 
      @key = key
      @keypath = path ? ( path + '/' + @key.to_s ) : key.to_s    
      super( "The attribute '#{@keypath}' is required but no value was given." )
    end

  end

  class InOptionError < Error 
    
    attr_reader :keypath 
    attr_reader :key 

    def initialize( path: nil, key:, option:, value: )
      path = path ? path.chomp( '/' ) : nil 
      @key = key
      @keypath = path ? ( path + '/' + @key.to_s ) : key.to_s    
      super( "The attribute '#{@keypath}' must be in '#{option.to_s}' but '#{value.to_s}' was given." )
    end

  end

end
