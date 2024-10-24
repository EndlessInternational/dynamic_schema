module SchemaHelper

  def construct_builder( &block )   
    DynamicSchema::Builder.new.define( &block )
  end

end

RSpec.configure do | config |
  config.include SchemaHelper
end

