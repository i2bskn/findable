module Findable
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), "templates"))

      desc "Create seed_dir of Findable."
      def create_seed_dir
        create_file File.join("db", "findable_seeds", ".keep")
      end

      desc "Install Findable files"
      def install_findable_files
        template "seeds.rb", "db/findable_seeds.rb"
        template "findable.rb", "config/initializers/findable.rb"
      end
    end
  end
end

