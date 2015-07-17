require "yaml"
require "csv"

module Findable
  class UnknownSeedDir < FindableError
    def initialize(path)
      if path
        super("Couldn't find #{path}")
      else
        super("There is no configuration")
      end
    end
  end

  class Seed < Struct.new(:seed_files, :model_name)
    class << self
      def target_files(seed_dir: nil, seed_files: nil)
        target_dir = pathname(seed_dir || Findable.config.seed_dir)
        raise UnknownSeedDir.new(target_dir) unless target_dir.try(:exist?)

        seed_files = seed_files.map!(&:to_s) if seed_files
        _model_name = method(:model_name).to_proc.curry.call(target_dir)
        _selected = Proc.new do |seed|
          seed_files.present? ? seed.table_name.in?(seed_files) : true
        end

        Pathname.glob(target_dir.join("**", "*"))
          .select(&:file?)
          .group_by(&_model_name)
          .map {|name, files| new(files, name) }
          .select(&_selected)
      end

      def model_name(seed_dir, seed_file)
        if seed_dir != seed_file.dirname && seed_file.basename.to_s.match(/^data/)
          from_seed_dir(seed_dir, seed_file.dirname).to_s.classify
        else
          from_seed_dir(seed_dir, without_ext(seed_file)).to_s.classify
        end
      end

      def from_seed_dir(seed_dir, seed_file)
        pathname(seed_file).relative_path_from(seed_dir)
      end

      def without_ext(seed_file)
        pathname(seed_file).dirname.join(pathname(seed_file).basename(".*"))
      end

      def pathname(path)
        case path
        when Pathname then path
        when String then Pathname.new(path)
        else nil
        end
      end
    end

    def model
      @_model_class ||= model_name.constantize
    end

    def load_files
      seed_files.sort_by(&:to_s).inject([]) do |data, file|
        data | case file.extname
          when ".yml" then load_yaml(file)
          when ".csv" then load_csv(file)
          else
            raise UnknownFormat
          end
      end
    end

    def bootstrap!
      model.query.lock do
        model.delete_all
        model.query.import load_files
      end
    end

    private
      def load_yaml(seed_file)
        YAML.load_file(seed_file).values
      end

      def load_csv(seed_file)
        CSV.table(seed_file).map(&:to_h)
      end
  end
end
