module Findable
  module Store
    module Connection
      extend ActiveSupport::Concern

      module ClassMethods
        # Returns current connection or generate connection.
        # @return [Redis] Redis connection
        def redis
          @_redis ||= generate_redis_connection!
        end

        private
          # Generate connection with redis options or default connection.
          # @return [Redis] Redis connection
          def generate_redis_connection!
            redis_options ? Redis.new(*redis_options) : Redis.current
          end

          # Returns redis options from configuration.
          # @return [Hash] Redis options
          # @return [nil] No Redis options
          def redis_options
            Findable.config.redis_options.presence
          end
      end

      # Returns current connection from current class.
      # @return [Redis] Redis connection
      def redis
        self.class.redis
      end
    end
  end
end

