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
end

require "findable"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

