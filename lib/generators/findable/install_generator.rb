module Findable
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), "templates"))

      desc "Install Findable files"
      def install_findable_files
        template "seeds.rb", "db/findable_seeds.rb"
        template "findable.rb", "config/initializers/findable.rb"
      end
    end
  end
end

