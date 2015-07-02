module Findable
  class Seed
    class << self
      def target_files(seed_dir: nil, seed_files: nil)
        target_dir = pathname(seed_dir) || Findable.config.seed_dir
        raise ArgumentError unless target_dir
        Pathname.glob(target_dir.join("**", "*")).map {|full_path|
          new(full_path, target_dir)
        }.select {|seed|
          seed_files.present? ? seed_files.include?(seed.basename) : true
        }
      end

      def pathname(path)
        case path
        when Pathname then path
        when String then Pathname.new(path)
        else nil
        end
      end
    end

    def initialize(full_path, seed_dir)
      @_full_path = full_path
      @_seed_dir = seed_dir
    end

    def basename
      @_basename ||= @_full_path.basename(".*").to_s
    end

    def model
      @_model ||= from_seed_dir(without_ext(@_full_path)).to_s.classify.constantize
    end

    def bootstrap!
      model.query.lock do
        model.delete_all
        model.query.import YAML.load_file(@_full_path).values
      end
    end

    private
      def pathname(path)
        self.class.pathname(path)
      end

      def without_ext(path)
        pathname(path).dirname.join(pathname(path).basename(".*"))
      end

      def from_seed_dir(path)
        pathname(path).relative_path_from(@_seed_dir)
      end
  end
end
