require_relative 'dynamic_schema/errors'
require_relative 'dynamic_schema/builder'

require_relative 'dynamic_schema/definable'
require_relative 'dynamic_schema/buildable'

module DynamicSchema  
  def self.define( schema = {}, inherit: nil, &block )
    Builder.new( schema ).define( inherit: inherit, &block )
  end
end
