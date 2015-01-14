module Findable
  class Railtie < ::Rails::Railtie
    initializer "findable" do
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.send(:extend, Findable::Association)
      end
    end

    rake_tasks do
      load "tasks/findable.rake"
    end
  end
end

