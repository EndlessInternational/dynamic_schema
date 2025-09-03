module ReceiverHelper

  def build_receiver( values = nil, schema: )   
    DynamicSchema::Receiver::Object.new( 
      values, 
      schema: schema,
      converter: DynamicSchema::Converter
    )
  end

end

RSpec.configure do | config |
  config.include ReceiverHelper
end
