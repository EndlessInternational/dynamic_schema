require_relative 'dynamic_schema/errors'
require_relative 'dynamic_schema/builder'

module DynamicSchema  
  def self.define( schema = {}, &block )
    Builder.new( schema ).define( &block )
  end
end
