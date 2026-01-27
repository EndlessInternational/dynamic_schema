module ReceiverHelper

  def build_receiver( values = nil, schema:, defaults: true )   
    DynamicSchema::Receiver::Object.new( 
      values, 
      schema: schema,
      converter: DynamicSchema::Converter,
      defaults: defaults
    )
  end

end

RSpec.configure do | config |
  config.include ReceiverHelper
end
