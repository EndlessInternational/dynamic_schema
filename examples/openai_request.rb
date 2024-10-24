require_relative '../lib/dynamic_schema'
require 'net/http'
require 'json'
require 'debug'

headers_schema = DynamicSchema.define do 
  content_type    String, as: "Content-Type", default: "application/json"
  key             String, as: "Authorization", default: "Bearer #{ENV['OPENAI_API_KEY']}"
end

request_schema = DynamicSchema.define do 
  
  model           String, default: 'gpt-4o'
  max_tokens      Integer, default: 1024
  temperature     Float, in: 0..1

  message         arguments: [ :role ], as: :messages, array: true do 
    role          Symbol, in: [ :system, :user, :assistant ]
    content       array: true do 
      type        Symbol, default: :text 
      text        String
    end
  end

end

# we don't need to pass anything as the defaults meet the needs of the request
headers = headers_schema.build

# we'll rely on the defaults for the majority of the parameters; we'll just add messages
request = request_schema.build { 
  message :system do 
    content text: "You are a helpful assistant that talks like a pirate."
  end
  message :user do 
    content text: ARGV[0] || "say hello!"
  end
}

response = Net::HTTP.post( 
  URI( 'https://api.openai.com/v1/chat/completions' ), 
  request.to_json, 
  headers
)

if response.code.to_i.between?( 200, 299 ) && 
   result = JSON.parse( response.body ) rescue nil
  puts result[ 'choices' ][ 0 ][ 'message' ][ 'content' ]
else
  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"
end
