module Findable
  class Configuration
    VALID_OPTIONS = [
      :default_storage,
      :redis_options,
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
      self.default_storage = :redis
      self.redis_options = nil
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

