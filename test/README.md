# Test Guidelines

## Running Tests

```bash
bin/test          # run all minitest tests
bundle exec rspec # run rspec tests (legacy, to be removed)
```

## Directory Structure

Tests are organized hierarchically by component and feature permutations:

```
test/
├── test_helper.rb
├── README.md
├── converter_test.rb
├── modules_test.rb
├── builder/
│   ├── values_test.rb
│   ├── values/
│   │   ├── types_test.rb
│   │   └── coercion_test.rb
│   ├── objects_test.rb
│   ├── objects/
│   │   ├── array_test.rb
│   │   ├── arguments_test.rb
│   │   └── array/
│   │       └── arguments_test.rb
│   ├── options/
│   │   ├── default_test.rb
│   │   ├── required_test.rb
│   │   ├── array_test.rb
│   │   ├── as_test.rb
│   │   └── in_test.rb
│   ├── validation_test.rb
│   └── inheritance_test.rb
├── receiver/
│   ├── basics_test.rb
│   ├── defaults_test.rb
│   ├── coercion_test.rb
│   └── arrays_test.rb
└── struct/
    ├── basics_test.rb
    ├── nesting_test.rb
    ├── validation_test.rb
    └── to_h_test.rb
```

## Naming Conventions

### Files

- use snake_case for file names
- suffix all test files with `_test.rb`
- name files after the feature being tested, not the option name
  - `arguments_test.rb` not `arguments_option_test.rb`
  - `array_test.rb` not `array_option_test.rb`

### Directories

- use directories to represent feature permutations
- nest directories when testing combinations of features
  - `objects/array_test.rb` - tests array of objects
  - `objects/arguments_test.rb` - tests objects with arguments
  - `objects/array/arguments_test.rb` - tests array of objects with arguments

### Classes and Modules

- use modules to namespace related tests within a file
- do not include "Option" or "Test" suffix in module names
  - `module Default` not `module DefaultOption`
  - `module Array` not `module ArrayOption`
- class names should end with `Test`
  - `class BasicTest < Minitest::Test`

### Test Methods

- prefix all test methods with `test_`
- use descriptive names that explain what is being tested
- avoid abbreviations

```ruby
# good
def test_coerces_string_to_integer
def test_raises_for_missing_required_field

# bad
def test_str_to_int
def test_req_field_missing
```

## Code Style

### Spacing

follow project CODESTYLE.md:
- spaces inside parentheses: `method( arg )`
- spaces inside brackets: `array[ index ]`
- spaces inside block braces: `{ | block | ... }`

### Comments

- keep comments minimal
- use lowercase for comments
- explain why, not what

```ruby
# good
# coercion fails silently, value kept as-is
assert_equal 'not-an-integer', result[ :value ]

# bad
# Assert that the value equals 'not-an-integer'
assert_equal 'not-an-integer', result[ :value ]
```

## Test Organization

### Modules for Grouping

use modules to group related tests within a file:

```ruby
module Builder
  module Objects
    module Array

      class BasicTest < Minitest::Test
        # tests for basic array of objects
      end

      class WithDefaultsTest < Minitest::Test
        # tests for array of objects with defaults
      end

    end
  end
end
```

### Test Helpers

define helpers in `test_helper.rb`:

```ruby
module TestHelper
  def build_schema( &block )
    DynamicSchema::Builder.new.define( &block )
  end

  def build_receiver( values = nil, schema:, defaults: true )
    DynamicSchema::Receiver::Object.new(
      values,
      schema: schema,
      converter: DynamicSchema::Converter,
      defaults: defaults
    )
  end
end
```

include helpers in test classes:

```ruby
class BasicTest < Minitest::Test
  include TestHelper
end
```

## Permutation Testing

when a feature can combine with other features, create nested directories:

```
feature/
├── feature_test.rb           # basic feature tests
├── other_test.rb             # feature + other
└── other/
    └── another_test.rb       # feature + other + another
```

example for objects with array and arguments options:

```
objects/
├── objects_test.rb           # basic nested objects
├── array_test.rb             # objects with array: true
├── arguments_test.rb         # objects with arguments: [...]
└── array/
    └── arguments_test.rb     # objects with array: true AND arguments: [...]
```
