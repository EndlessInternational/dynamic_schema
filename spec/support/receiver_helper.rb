module ReceiverHelper

  DEFAULT_CONVERTERS = DynamicSchema::Builder::DEFAULT_CONVERTERS 

  def build_receiver( values = nil, schema: )   
    DynamicSchema::Receiver::Object.new( 
      values, 
      converters: DEFAULT_CONVERTERS, 
      schema: schema 
    )
  end

end

RSpec.configure do | config |
  config.include ReceiverHelper
end
