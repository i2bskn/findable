require "findable/query/connection"
require "findable/query/namespace"
require "findable/query/lock"

module Findable
  class Query
    include Connection
    include Namespace

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def all
      deserialize(redis.hvals(data_key), model)
    end

    def ids
      redis.hkeys(data_key).map(&:to_i)
    end

    def count
      redis.hlen(data_key)
    end

    def find_by_ids(ids)
      deserialize(redis.hmget(data_key, *Array(ids)), model)
    end

    def exists?(id)
      redis.hexists(data_key, id)
    end

    def insert(object)
      att = script_insert(Array(object.attributes)).first
      object.attributes.merge!(att)
      object
    end

    def delete(objects)
      delete_ids = Array(objects).map(&:id)
      script_delete(delete_ids)
    end

    def delete_all
      redis.multi do
        eval_keys.each {|key| redis.del(key) }
      end
    end

    def lock
      raise ArgumentError, "Require block" unless block_given?
      Lock.new(lock_key, thread_key).lock { yield }
    end

    # Lua Script API

    # Insert and update data of Findable.
    #
    # @param hashes [Array<Hash>] Attributes
    # @return [Array<Hash>]
    def script_insert(hashes)
      eval_arguments = hashes.map(&:to_msgpack)
      RedisEval.insert.execute(eval_keys, eval_arguments).map {|packed|
        MessagePack.unpack(packed)
      }
    end
    alias_method :import, :script_insert

    # Delete data of Findable with index.
    #
    # @param ids [Array<Integer>] Delete target ids.
    # @return [Integer] Deleted count.
    def script_delete(ids)
      RedisEval.delete.execute(eval_keys, Array(ids))
    end

    private
      def eval_keys
        [
          data_key,
          info_key,
          model.secondary_indexes.map {|idx| index_key(idx) },
        ].flatten
      end

      def deserialize(raw_data, klass = nil)
        objects = Array(raw_data).compact.map {|data|
          object = MessagePack.unpack(data)
          object = object.with_indifferent_access if object.is_a?(Hash)
          klass ? klass.new(object) : object
        }
        raw_data.is_a?(String) ? objects.first : objects
      end
  end
end
