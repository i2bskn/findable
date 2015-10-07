require "findable/query/connection"
require "findable/query/namespace"
require "findable/query/lock"
require "findable/script"

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

    def find_by_index(index, value)
      if ids = ids_from_index([index, value].join(":"))
        find_by_ids(ids)
      end
    end

    def exists?(id)
      redis.hexists(data_key, id)
    end

    def insert(object)
      lock do
        packed_objects = Script.insert.execute(
          script_keys,
          [object.id || "auto", object.attributes.to_msgpack],
        )
        object.attributes.merge!(MessagePack.unpack(packed_objects.first))
        update_index(object)
      end
      object
    end

    def import(hashes)
      lock do
        indexes = Hash.new {|h, k| h[k] = [] }
        values = hashes.each_with_object([]) do |hash, obj|
          hash = hash.with_indifferent_access
          hash["id"] = auto_incremented_id(hash["id"])
          obj << hash["id"]
          obj << hash.to_msgpack

          if model.index_defined?
            model.indexes.each_with_object([]) do |name, obj|
              next if name == :id
              indexes[[name, hash[name]].join(":")] << hash["id"]
            end
          end
        end
        redis.hmset(data_key, *values)
        if indexes.present?
          attrs = indexes.map {|k, v| [k, v.to_msgpack] }.flatten
          redis.hmset(index_key, *attrs)
        end
      end
    end

    def delete(object)
      if model.index_defined?
        model.indexes.each do |name|
          next if name == :id
          if value = object.public_send("#{name}_was") || object.public_send(name)
            redis.hdel(index_key, value)
          end
        end
      end

      redis.hdel(data_key, object.id)
    end

    def delete_all
      redis.multi do
        [data_key, info_key, index_key].each {|key| redis.del(key) }
      end
    end

    def lock
      raise ArgumentError, "Require block" unless block_given?
      Lock.new(lock_key, thread_key).lock { yield }
    end

    def update_index(object)
      if model.index_defined?
        indexes = model.indexes.each_with_object([]) {|name, obj|
          next if name == :id || object.public_send("#{name}_changed?")

          if old_value = object.public_send("#{name}_was")
            old_index_key = [name, old_value].join(":")

            if (old_ids = ids_from_index(old_index_key)).present?
              new_ids = old_ids.reject {|id| id == object.id }
              if new_ids.empty?
                redis.hdel(index_key, old_index_key)
              else
                obj << old_index_key
                obj << new_ids.to_msgpack
              end
            end
          end

          obj << [name, object.public_send(name)].join(":")
          obj << object.id
        }
        redis.hmset(index_key, *indexes)
      end
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

      def ids_from_index(index_name)
        if ids = redis.hget(index_key, index_name)
          deserialize(ids)
        end
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
