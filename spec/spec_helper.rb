require "simplecov"
require "coveralls"
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter "spec"
  add_filter ".bundle"
  add_filter "example"
end

require "pry"
require "findable"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.after(:each) { Findable.config.reset }
end

