module Findable
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/findable.rake"
    end
  end
end

