require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../lib/dynamic_schema'

module TestHelper

  def build_receiver( values = nil, schema:, defaults: true )
    DynamicSchema::Receiver::Object.new(
      values,
      schema: schema,
      converter: DynamicSchema::Converter,
      defaults: defaults
    )
  end

  def build_schema( &block )
    DynamicSchema::Builder.new.define( &block )
  end

end
