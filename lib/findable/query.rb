require "findable/query/connection"
require "findable/query/namespace"
require "findable/query/lock"

module Findable
  class Query
    include Connection
    include Namespace

    def data
      redis.hvals(data_key)
    end

    def ids
      redis.hkeys(data_key).map(&:to_i)
    end

    def count
      redis.hlen(data_key)
    end

    def find_by_ids(ids)
      redis.hmget(data_key, *Array(ids))
    end

    def exists?(id)
      redis.hexists(data_key, id)
    end

    def insert(hash)
      lock do
        hash[:id] = auto_incremented_id(hash[:id])
        redis.hset(data_key, hash[:id], serializer.dump(hash))
      end
      hash
    end

    def import(hashes)
      lock do
        auto_incremented = hashes.each_with_object([]) do |hash, obj|
          hash["id"] = auto_incremented_id(hash["id"])
          obj << hash["id"]
          obj << serializer.dump(hash)
        end
        redis.hmset(data_key, *auto_incremented)
      end
    end

    def delete(id)
      redis.hdel data_key, id
    end

    def delete_all
      redis.multi do
        [data_key, info_key].each {|key| redis.del(key) }
      end
    end

    def lock
      raise ArgumentError, "Require block" unless block_given?
      Lock.new(lock_key, thread_key).lock { yield }
    end

    private
      def auto_incremented_id(id)
        if id.present?
          current = redis.hget(info_key, AUTO_INCREMENT_KEY).to_i
          id = id.to_i
          if id > current
            redis.hset(info_key, AUTO_INCREMENT_KEY, id)
          end
          id
        else
          redis.hincrby(info_key, AUTO_INCREMENT_KEY, 1)
        end
      end

      def serializer
        Findable.config.serializer
      end
  end
end
