# DynamicSchema

The **DynamicSchema** gem provides a elegant and expressive way to define a domain-specific 
language (DSL) schemas, making it effortless to build and validate complex Ruby `Hash` 
constructs. 

This is particularly useful when dealing with intricate configuration or interfacing with 
external APIs, where data structures need to adhere to specific formats and validations. 
By allowing default values, type constraints, nested schemas, and transformations, 
DynamicSchema ensures that your data structures are both robust and flexible. 

You can trivially define a custom schema:

```ruby
openai_request_schema = DynamicSchema.define do 
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
```

And then repetedly use that schema to elegantly build a schema conformant `Hash`:
```ruby
request = openai_request_schema.build {
  message :system do 
    content text: "You are a helpful assistant that talks like a pirate."
  end
  message :user do 
    content text: ARGV[0] || "say hello!"
  end
}
```

You can find a full OpenAI request example in the `/examples` folder of this repository.

---

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Values](#values)
- [Objects](#objects)
- [Types](#types)
- [Options](#options)
  - [default Option](#default-option)
  - [required Option](#required-option)
  - [array Option](#array-option)
  - [as Option](#as-option)
  - [in Option (Values Only)](#in-option)
  - [arguments Option](#arguments-option)
- [Validation Methods](#validation-methods)
  - [Validation Rules](#validation-rules) 
  - [validate!](#validate)
  - [validate](#validate-1)
  - [valid?](#valid)
- [Error Types](#error-types)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamicschema'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install dynamicschema
```

## Usage

### Requiring the Gem

To start using the `dynamic_schema` gem, simply require it in your Ruby file:

```ruby
require 'dynamic_schema'
```

### Defining Schemas with **DynamicSchema**

DynamicSchema permits the caller to define a domain specific language (DSL) schema with *values*, 
*objects* and related *options*. You can use the `DynamicSchema.define` convenience method, or 
instantiate `DynamicSchema::Builder`, then call it's `define` method, to prepare a builder.

In all cases the `define` methods require a block where the names of schema components as well as 
their options are specified. 

Once a schema is defined you may repeatedly use the `Builder` instance to 'build' a Hash of values 
using the DSL you've defined. The builder has a 'build' method which will construct a Hash without 
validating the values. If you've specified that a value should be of a specific type and an 
incompatible type was given that type will be in the Hash with no indication of that violation. 
Alterativelly, you can call the `build!` method which will validate the Hash, raising an exception
if any of the schema criteria is violated. 

Finally, you can use a builder to validate a given Hash against the schema you've defined using 
the `validate`, `validate!` and `valid?` `Builder` instance methods.

---

## Values 

A *value* is the basic building blocks of your schema. Values represent individual settings, 
options or API paramters that you can define with specific types, defaults, and other options.

When defining a value, you provide the name as though you were calling a Ruby method, with 
arguments that include an optional type (which can be a `Class`, `Module` or an `Array` of these ) 
as well as a `Hash` of options, all of which are optional: 

`name {type} default: {true|false}, required: {true|false}, array: {true|false}, as: {name}, in: {Array|Range}`

#### example:

```ruby
require 'dynamic_schema'

# define a schema structure with values
schema = DynamicSchema::Builder.new.define do
  api_key
  version, String, default: '1.0'
end

# build the schema and set values
result = schema.build! do
  api_key 'your-api-key'
end

# access the schema values
puts result[:api_key]     # => "your-api-key"
puts result[:version]     # => "1.0"
```

- defining
  - `api_key` defines a value named `api_key`. Any type can be used to assign the value.
  - `version, String, default: '1.0'` defines a value with a default.
- building 
  - `schema.build!` build accepts both a Hash and a block where you can set the values.
  - Inside the block, `api_key 'your-api-key'` sets the value of `api_key`.
- accessing 
  - `result[:api_key]` retrieves the value of `api_key`.
  - If a value has a default and you don't set it, the default value will be included in 
    resulting hash.

---

## Objects

A schema may be organized hierarchically, by creating collections of related values and 
even other collections. These collections are called objects. 

An *object* is defined in a similar manner to a value. Simply provide the name as though 
calling a Ruby method, with a Hash of options and a block which encloses the child values 
and objects:

```
name arguments: [ {argument} ], default: {true|false}, required: {true|false}, array: {true|false}, as: {name} do 
  # child values and objects can be defined here
end 
```

Notice an *object* does not accept a type as it is always of type `Object`.

#### example:

```ruby
require 'dynamic_schema'

schema = DynamicSchema::Builder.new do
  api_key, String
  chat_options do
    model String, default: 'claude-3'
    max_tokens Integer, default: 1024
    temperature, Float, default: 0.5, in: 0..1
    stream [ TrueClass, FalseClass ]
  end
end

result = schema.build! do
  api_key 'your-api-key'
  chat_options do
    temperature 0.8
    stream true
  end
end

# Accessing values
puts result[:api_key]                     # => "your-api-key"
puts result[:chat_options][:model]        # => "claude-3"
puts result[:chat_options][:temperature]  # => 0.8
puts result[:chat_options][:stream]       # => true
```

- defining
  - `chat_options do ... end` defines an object named `chat_options`.
  - Inside the object you can define values that belong to that object.
- building 
  - In the build block, you can set values for values within objects by nesting blocks.
  - `chat_options do ... end` allows you to set values inside the `chat_options` object.
- accessing
  - You access values by chaining the keys: `result[:chat_options][:model]`.

---

## Types 

An *object* is always of type `Object`. A *value* can have no type or it can be of one or 
more types. You specify the value type by providing an instance of a `Class` when defining 
the value. If you want to specify multiple types simply provide an array of types.

#### example:

```ruby
require 'dynamic_schema'

schema = DynamicSchema::Builder.new do
  typeless_value
  symbol_value      Symbol 
  boolean_value     [ TrueClass, FalseClass ]
end

result = schema.build! do
  typeless_value    Struct.new(:name).new(name: 'Kristoph')
  symbol_value      "something"
  boolean_value     true 
end 

puts result[:typeless_value].name             # => "Kristoph"
puts result[:symbol_value]                    # => :something
puts result[:boolean_value]                   # => true 
```

- defining
  - `typeless_value` defines a value that has no type and will accept an assignment of any type 
  - `symbol_value` defines a value that accepts symbols or types that can be coerced into 
    symbols, such as strings (see **Type Coercion**) 
  - `boolean_value` defines a value that can be either `true` or `false`

## Options 

Both *values* and *objects* can be customized through *options*. The options for both values and
objects include `default`, `required`, `as` and `array`. In addition values support the `in`
criteria option while objects support the `arguments` option. 

### :default Option 

The `:default` option allows you to specify a default value that will be used if no value is 
provided during build.

#### example:

```ruby
schema = DynamicSchema.define do
  api_version String, default: 'v1'
  timeout Integer, default: 30
end

result = schema.build!
puts result[:api_version]  # => "v1"
puts result[:timeout]      # => 30
```

### :required Option

The `:required` option ensures that a value must be provided when building the schema. If a 
required value is missing when using `build!`, `validate`, or `validate!`, 
a `DynamicSchema::RequiredOptionError` will be raised.

#### example:

```ruby
schema = DynamicSchema.define do
  api_key String, required: true
  timeout Integer, default: 30
end

# This will raise DynamicSchema::RequiredOptionError
result = schema.build!

# This is valid
result = schema.build! do
  api_key 'my-secret-key'
end
```

### :array Option

The `:array` option wraps the value or object in an array in the resulting Hash, even if only 
one value is provided. This is particularly useful when dealing with APIs that expect array 
inputs.

#### example:

```ruby
schema = DynamicSchema.define do
  tags String, array: true
  message array: true do
    text String
    type String, default: 'plain'
  end
end

result = schema.build! do
  tags 'important'
  message do
    text 'Hello world'
  end
end

puts result[:tags]      # => ["important"]
puts result[:message]   # => [{ text: "Hello world", type: "plain" }]
```

### :as Option

The `:as` option allows you to use a different name in the DSL than what appears in the final 
Hash. This is particularly useful when interfacing with APIs that have specific key 
requirements.

#### example:

```ruby
schema = DynamicSchema.define do
  content_type String, as: "Content-Type", default: "application/json"
  api_key String, as: "Authorization"
end

result = schema.build! do
  api_key 'Bearer abc123'
end

puts result["Content-Type"]    # => "application/json"
puts result["Authorization"]   # => "Bearer abc123"
```

### :in Option

The `:in` option provides validation for values, ensuring they fall within a specified Range or 
are included in an Array of allowed values. This option is only available for values.

#### example:

```ruby
schema = DynamicSchema.define do
  temperature Float, in: 0..1
  status String, in: ['pending', 'processing', 'completed']
end

# Valid
result = schema.build! do
  temperature 0.7
  status 'pending'
end

# Will raise validation error - temperature out of range
result = schema.build! do
  temperature 1.5
  status 'pending'
end

# Will raise validation error - invalid status
result = schema.build! do
  temperature 0.7
  status 'invalid'
end
```

### :arguments Option 

The `:arguments` option allows objects to accept arguments when building. Any arguments provided
must appear when the object is built ( and so are implicitly 'required' ).

If the an argument is provided, the same argument appears in the attributes hash, or in the object 
block, the assignemnt in the block will take priority, followed by the attributes assigned and 
finally the argument. 

#### example:

```ruby
schema = DynamicSchema.define do
  message arguments: [ :role ], as: :messages, array: true do
    role Symbol, required: true, in: [ :system, :user, :assistant ]
    content String
  end
end

result = schema.build! do
  message :system do
    content "You are a helpful assistant."
  end
  message :user do
    content "Hello!"
  end
end
```

## Validation

DynamicSchema provides three different methods for validating Hash structures against your 
defined schema: `validate!`, `validate`, and `valid?`. 

These methods allow you to verify that your data conforms to your schema's requirements, 
including type constraints, required fields, and value ranges.

### Validation Rules

When validating, DynamicSchema checks:

1. **Required Fields**: 
   Any value or object marked as `required: true` are present.
2. **Type Constraints**: 
   Any values match their specified types or can be coerced to the specified type.
3. **Value Ranges**:
   Any values fall within their specified `:in` constraints.
4. **Objects**: 
   Any objects are recursively validates.
5. **Arrays**: 
   Any validation rules are applied to each element when `array: true`

### validate!

The `validate!` method performs strict validation and raises an exception when it encounters 
the first validation error.

#### example:

```ruby
schema = DynamicSchema.define do
  api_key String, required: true
  temperature Float, in: 0..1
end

# this will raise DynamicSchema::RequiredOptionError
schema.validate!( { temperature: 0.5 } )

# this will raise DynamicSchema::IncompatibleTypeError
schema.validate!( {
  api_key: ["not-a-string"],            
  temperature: 0.5
} )

# this will raise DynamicSchema::InOptionError
schema.validate!( {
  api_key: "abc123",
  temperature: 1.5     
} )

# this is valid and will not raise any errors
schema.validate!( {
  api_key: 123,  
  temperature: 0.5
} )
```

### validate

The `validate` method performs validation but instead of raising exceptions, it collects and 
returns an array of all validation errors encountered.

#### example:

```ruby
schema = DynamicSchema.define do
  api_key String, required: true
  model String, in: ['gpt-3.5-turbo', 'gpt-4']
  temperature Float, in: 0..1
end

errors = schema.validate({
  model: 'invalid-model',
  temperature: 1.5,
  api_key: ["invalid-type"]  # Array cannot be coerced to String
})

# errors will contain:
# - IncompatibleTypeError for api_key being an Array
# - InOptionError for invalid model
# - InOptionError for temperature out of range
```

### valid?

The `valid?` method provides a simple boolean check of whether a Hash conforms to the schema.

#### example:

```ruby
schema = DynamicSchema.define do
  name String, required: true
  age Integer, in: 0..120
  id String  # Will accept both strings and numbers due to coercion
end

# Returns false
schema.valid?({
  name: ["Not a string"],  # Array cannot be coerced to String
  age: 150                 # Outside allowed range
})

# Returns true
schema.valid?({
  name: "John",
  age: 30,
  id: 12345               # Numeric value can be coerced to String
})
```

### Error Types

DynamicSchema provides specific error types for different validation failures:

- `DynamicSchema::RequiredOptionError`: Raised when a required field is missing
- `DynamicSchema::IncompatibleTypeError`: Raised when a value's type doesn't match the schema 
  and cannot be coerced
- `DynamicSchema::InOptionError`: Raised when a value falls outside its specified range/set
- `ArgumentError`: Raised when the provided values structure isn't a Hash

Each error includes helpful context about the validation failure, including the path to the failing field and the specific constraint that wasn't met.

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/EndlessInternational/adaptive-schema](https://github.com/EndlessInternational/dynamic-schema).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
