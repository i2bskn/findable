require "findable/associations"

module Findable
  class Base
    include ActiveModel::Model
    include ActiveModel::AttributeMethods

    include Associations

    attribute_method_suffix "="
    attribute_method_suffix "?"

    class << self
      ## field definitions

      def define_field(attr)
        unless public_method_defined?(attr)
          define_attribute_methods attr
          define_method(attr) { attributes[attr.to_sym] }
          column_names << attr.to_sym
        end
      end

      ## ActiveRecord like APIs

      def primary_key
        "id"
      end

      def column_names
        @_column_names ||= [:id]
      end

      def all
        data.map {|val| new(val) }
      end

      def find(ids)
        if values = find_by_ids(ids).compact.presence
          ids.is_a?(Array) ? values.map {|val| new(val) } : new(values.first)
        else
          raise RecordNotFound.new(self, id: ids)
        end
      end

      def find_by(conditions)
        if conditions.is_a?(Hash)
          conditions.symbolize_keys!
          if id = conditions.delete(:id)
            values = find_by_ids(id).compact
            case
            when values.empty? then nil
            when conditions.empty? then new(values.first)
            else
              value = values.detect {|val|
                record = new(val)
                conditions.all? {|k, v| record.public_send(k) == v }
              }
              value ? new(value) : nil
            end
          else
            all.detect {|r|
              conditions.all? {|k, v| r.public_send(k) == v }
            }
          end
        else
          values = find_by_ids(conditions).compact
          values.empty? ? nil : new(values.first)
        end
      end

      def find_by!(conditions)
        find_by(conditions.dup) || (raise RecordNotFound.new(self, conditions))
      end

      def where(conditions)
        if id = conditions.delete(:id)
          values = find_by_ids(id).compact
          if conditions.empty?
            values.map {|val| new(val) }
          else
            values.map {|val|
              record = new(val)
              conditions.all? {|k, v| record.public_send(k) == v } ? record : nil
            }.compact
          end
        else
          all.select {|r|
            conditions.all? {|k, v| r.public_send(k) == v }
          }
        end
      end

      def create(attrs = {})
        record = new(attrs)
        record.save
        record
      end
      alias_method :create!, :create

      [:first, :last].each do |m|
        define_method(m) do
          value = self.data.public_send(m)
          value ? new(value) : nil
        end
      end

      ## Query APIs

      delegate :find_by_ids, :data, to: :query
      delegate :count, :ids, :delete_all, to: :query
      alias_method :destroy_all, :delete_all

      def exists?(obj)
        if _id = id_from(obj)
          query.exists?(_id)
        else
          false
        end
      end

      def insert(obj)
        query.insert(obj.attributes)
      end

      def delete(obj)
        if _id = id_from(obj)
          query.delete(_id)
        end
      end

      def query
        @_query ||= Query.new(self)
      end

      private
        def id_from(obj)
          obj.is_a?(self) ? obj.id : obj.to_i
        end
    end

    def initialize(params = {})
      params = Oj.load(params) if params.is_a?(String)
      params.symbolize_keys!
      params.keys.each {|attr| self.class.define_field(attr) }
      @_attributes = params
    end

    def id
      attributes[:id].presence
    end

    def id=(value)
      attributes[:id] = value
    end

    def hash
      id.hash
    end

    def new_record?
      id ? !self.class.exists?(self) : true
    end

    def persisted?
      !new_record?
    end

    def save
      @_attributes = self.class.insert(self)
      self
    end
    alias_method :save!, :save

    def delete
      self.class.delete(self)
    end
    alias_method :destroy, :delete

    def attributes
      @_attributes ||= {}
    end

    private
      def attribute=(attr, value)
        attributes[attr.to_sym] = value
      end

      def attribute?(attr)
        attributes[attr.to_sym].present?
      end
  end
end
