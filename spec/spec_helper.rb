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

require "bundler/setup"
require "active_record"
require "sqlite3"
require "pry"

require "findable"
require "findable/associations/active_record_ext"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.order = :random
  config.after(:each) { Findable.config.reset }
end
