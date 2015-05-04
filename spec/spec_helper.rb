require "findable"
require "coveralls"
Coveralls.wear!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.after(:each) { Findable.config.reset }
end

