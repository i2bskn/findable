module Findable
  class Configuration
    VALID_OPTIONS = [
      :redis_options,
      :serializer,
      :seed_dir,
      :seed_file,
    ].freeze

    attr_accessor *VALID_OPTIONS

    def initialize
      reset
    end

    def configure
      yield self
    end

    def merge(params)
      self.dup.merge!(params)
    end

    def merge!(params)
      params.keys.each {|key| self.send("#{key}=", params[key]) }
      self
    end

    def reset
      self.redis_options = nil
      self.serializer = JSON
      self.seed_dir = defined?(Rails) ? Rails.root.join("db", "findable_seeds") : nil
      self.seed_file = defined?(Rails) ? Rails.root.join("db", "findable_seeds.rb") : nil
    end

    module Accessible
      def configure(options = {}, &block)
        config.merge!(options) unless options.empty?
        config.configure(&block) if block_given?
      end

      def config
        @_config ||= Configuration.new
      end
    end
  end

  extend Configuration::Accessible
end
