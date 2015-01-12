require "findable/recordable"
require "findable/connection"
require "findable/namespace"

module Findable
  class Base
    include ActiveModel::Model
    include Recordable
    include Connection
    include Namespace

    class << self
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

        case
        when values.empty? then nil
        when ids.is_a?(Array) then values.map {|val| new(val)}
        else new(values.first)
        end
      end

      def find_by(params)
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

      def create!(attrs = {})
        record = new(attrs)
        record.save!
        record
      end

      def delete_all
        redis.del(data_key)
      end

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

