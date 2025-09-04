require 'rspec'
require 'debug'
require 'dynamic_schema'

Dir[ File.join( __dir__, 'support', '**', '*.rb' ) ].each { |f| require f }

RSpec.configure do | config |

  config.formatter = :documentation

  config.expect_with :rspec do | expectations |
    expectations.syntax = :expect
  end

  config.mock_with :rspec do | mocks |
    mocks.syntax = :expect
  end

  # allows using "describe" instead of "RSpec.describe"
  config.expose_dsl_globally = true

end
