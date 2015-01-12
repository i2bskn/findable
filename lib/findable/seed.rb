module Findable
  class Seed
    attr_reader :full_path, :namespaced, :ext

    def initialize(path, seed_dir)
      @_seed_dir = seed_dir
      self.full_path = path
    end

    def full_path=(path)
      @full_path = path
      _path = path.gsub(@_seed_dir, "")
      @namespaced = /^\// =~ _path ? _path.from(1) : _path
      @ext = @namespaced[/^.*(?<ext>\.[^\.]+)$/, :ext] || (raise ArgumentError)
    end

    def base_name
      @_base ||= @namespaced.sub(@ext, "")
    end

    def model
      base_name.split("/").reverse.map.with_index {|n,i|
        i.zero? ? n.singularize : n
      }.reverse.map(&:camelize).join("::").constantize
    end

    def load_file
      case @ext
      when ".yml"
        YAML.load_file(@full_path).values
      else
        raise UnexpectedFormat
      end
    end

    def bootstrap!
      model.transaction do
        model.delete_all
        records = load_file.map {|data| model.new(data) }
        model.import records
      end
    end

    class << self
      def target_files(seed_dir, tables = nil)
        Dir.glob(patterns(seed_dir)).map {|full_path|
          Seed.new(full_path, seed_dir)
        }.select {|seed|
          tables ? tables.include?(seed.base_name) : true
        }
      end

      def patterns(seed_dir)
        %w(yml).map {|format|
          Rails.root.join("#{seed_dir}/**/*.#{format}").to_s
        }
      end
    end
  end
end

