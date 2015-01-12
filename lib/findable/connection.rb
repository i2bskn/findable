module Findable
  module Connection
    extend ActiveSupport::Concern

    module ClassMethods
      def redis
        @_redis ||= generate_redis_connection!
      end

      private
        def generate_redis_connection!
          redis_options ? Redis.new(*redis_options) : Redis.current
        end

        def redis_options
          Findable.config.redis_options.presence
        end
    end

    def redis
      self.class.redis
    end
  end
end

