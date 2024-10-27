Gem::Specification.new do | spec |

  spec.name           = 'dynamicschema'
  spec.version        = '1.0.0.beta03'
  spec.authors        = [ 'Kristoph Cichocki-Romanov' ]
  spec.email          = [ 'rubygems.org@kristoph.net' ]

  spec.summary        = <<~TEXT.gsub( /(?<!\n)\n(?!\n)/, ' ').strip    
    DynamicSchema is a lightweight and simple yet powerful gem that enables flexible semantic  
    schema definitions for constructing and validating complex configurations and other similar 
    payloads.  
  TEXT
  spec.description    = <<~TEXT.gsub( /(?<!\n)\n(?!\n)/, ' ').strip     
    The DynamicSchema gem provides a elegant and expressive way to define a domain-specific 
    language (DSL) schemas, making it effortless to build and validate complex Ruby hashes. 

    This is particularly useful when dealing with intricate configurations or 
    interfacing with external APIs, where data structures need to adhere to specific formats 
    and validations. By allowing default values, type constraints, nested schemas, and 
    transformations, DynamicSchema ensures that your data structures are both robust and 
    flexible.  
  TEXT

  spec.license        = 'MIT'
  spec.homepage       = 'https://github.com/EndlessInternational/dynamic_schema'
  spec.metadata       = {
    'source_code_uri'   => 'https://github.com/EndlessInternational/dynamic_schema',
    'bug_tracker_uri'   => 'https://github.com/EndlessInternational/dynamic_schema/issues',
#    'documentation_uri' => 'https://github.com/EndlessInternational/dynamic_schema'
  }

  spec.required_ruby_version = '>= 3.0'
  spec.files         = Dir[ "lib/**/*.rb", "LICENSE", "README.md", "dynamicschema.gemspec" ]
  spec.require_paths = [ "lib" ]

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'debug', '~> 1.9'

end
