require_relative 'dynamic_schema/errors'

require_relative 'dynamic_schema/validator'
require_relative 'dynamic_schema/converter'
require_relative 'dynamic_schema/builder'

require_relative 'dynamic_schema/definable'
require_relative 'dynamic_schema/buildable'

require_relative 'dynamic_schema/struct'

module DynamicSchema  
  def self.define( inherit: nil, &block )
    Builder.new.define( inherit: inherit, &block )
  end
end
