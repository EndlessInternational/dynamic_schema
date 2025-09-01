require_relative 'dynamic_schema/errors'
require_relative 'dynamic_schema/builder'

require_relative 'dynamic_schema/definable'
require_relative 'dynamic_schema/buildable'

module DynamicSchema  
  def self.define( inherit: nil, &block )
    Builder.new.define( inherit: inherit, &block )
  end
end
