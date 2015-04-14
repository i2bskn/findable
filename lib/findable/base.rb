require "findable/associations"
require "findable/recordable"
require "findable/store/connection"
require "findable/store/namespace"

module Findable
  class Base
    include ActiveModel::Model
    include Recordable
    include Store::Connection
    include Store::Namespace
    extend Association

    class << self
      alias_method :build, :new

      def primary_key
        "id"
      end

      def column_names
        raise NotImplementedError
      end

      def all
        all_data.map {|data| new(data) }
      end

      def find(*ids)
        ids = ids.first if ids.size == 1
        values = find_by_id(ids)
        raise RecordNotFound.new(self, id: ids) if values.empty?
        ids.is_a?(Array) ? values.map {|val| new(val)} : new(values.first)
      end

      def find_by(params)
        if params.is_a?(Hash)
          params.symbolize_keys!
          if id = params.delete(:id)
            values = find_by_id(id)
            return nil if values.empty?
            return new(values.first) if params.empty?

            values.each {|val|
              record = new(val)
              return record if params.all? {|k,v| record.send(k) == v }
            }
          else
            all_data.each {|val|
              record = new(val)
              return record if params.all? {|k,v| record.send(k) == v }
            }
          end
        else
          values = find_by_id(params)
          values.empty? ? nil : new(values.first)
        end
      end

      def find_by!(params)
        find_by(params) || (raise RecordNotFound.new(self, params))
      end

      def where(params)
        all.select {|record| params.all? {|k,v| record.send(k) == v } }
      end

      def exists?(record)
        if record.is_a?(self)
          _id = record.id
          return false unless _id
        else
          _id = record.to_i
        end

        redis.hexists data_key, _id
      end

      delegate :first, :last, to: :all

      def count
        redis.hlen(data_key)
      end

      def ids
        redis.hkeys(data_key).map(&:to_i)
      end

      def create(attrs = {})
        record = new(attrs)
        record.save
        record
      end
      alias_method :create!, :create

      def delete_all
        redis.del(data_key)
      end
      alias_method :destroy_all, :delete_all

      def transaction(&block)
        redis.multi &block
      end

      def import(records)
        data = records.each_with_object([]) {|record, obj|
          record.id ||= auto_incremented_id
          obj << record.id
          obj << record.to_json
        }
        redis.hmset(data_key, *data)
      end

      def insert(record)
        record.id ||= auto_incremented_id
        redis.hset(data_key, record.id, record.to_json)
      end

      def delete(id)
        redis.hdel(data_key, id)
      end

      private
        def auto_incremented_id
          redis.hincrby(info_key, :auto_inclement, 1)
        end

        def all_data
          redis.hvals(data_key)
        end

        def find_by_id(id)
          redis.hmget(data_key, *Array(id)).compact
        end
    end
  end
end

