require "findable/query/connection"

module Findable
  class Query
    class Lock
      include Findable::Query::Connection

      def initialize(lock_key, thread_key, options = {})
        @lock_key = lock_key
        @thread_key = thread_key
        @options = options.symbolize_keys!
      end

      def lock
        if Thread.current[@thread_key]
          yield
        else
          Thread.current[@thread_key] = true
          try_lock!(Time.current)
          begin
            yield
          ensure
            Thread.current[@thread_key] = nil
            unlock!
          end
        end
      end

      def unlock!
        redis.del(@lock_key)
      end

      private
        def try_lock!(start)
          loop do
            break if redis.setnx(@lock_key, expiration)

            current = redis.get(@lock_key).to_f
            if current < Time.current.to_f
              old = redis.getset(@lock_key, expiration).to_f
              break if old < Time.current.to_f
            end

            Kernel.sleep(0.1)
            raise Findable::LockTimeout if (Time.current.to_f - start) > timeout
          end
        end

        def expiration
          (Time.current + timeout).to_f
        end

        def timeout
          (@options[:timeout] || 5).to_f
        end
    end
  end
end
