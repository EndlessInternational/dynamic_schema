# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2025-01-27

### Added

- `normalize` option for values and objects that accepts a lambda or Proc to transform values upon assignment
- When used with arrays, the normalizer is called for each individual item
- Normalization occurs after type coercion
- Exceptions raised in normalize lambdas propagate to the caller

## [2.1.0] - 2025-01-27

### Added

- Support for multiple types with nested schemas (e.g., `[ Object, TrueClass, FalseClass ]` with a block)
- Fields can now be either a structured nested object or a scalar type, determined at runtime
- Custom type support allowing any Ruby class as a value type
- Block-based configuration for custom type instances

### Changed

- Replaced RSpec test suite with Minitest for better organization
- Added ability to disable defaults with `defaults: false` option in build

## [2.0.0] - 2025-09-06

### Added

- `DynamicSchema::Struct` for generating lightweight Ruby classes from schemas
- Struct instances expose readers and writers for defined fields
- Nested objects accessible via dot notation instead of hash indexing
- `to_h` method for converting struct instances back to hashes
- Struct validation via `valid?`, `validate`, and `validate!` methods
- `build!` method for structs that validates immediately
- Support for referencing other struct classes as value types
- Schema inheritance via `inherit:` option in `DynamicSchema.define`
- `build_from_bytes` and `build_from_file` methods for building from external sources
- `Converter` module for centralized type coercion
- `Validator` module for centralized validation logic

### Changed

- Reorganized internal architecture with `Compiler`, `Receiver::Object`, and `Receiver::Value`
- Enhanced type coercion with support for arrays of types
