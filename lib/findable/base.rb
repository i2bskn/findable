require "findable/associations"
require "findable/inspection"

module Findable
  class Base
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include Associations
    include Inspection

    attribute_method_suffix "="
    attribute_method_suffix "?"

    class << self
      ## field definitions

      def define_field(attr)
        unless public_method_defined?(attr)
          define_attribute_methods attr
          define_method(attr) { attributes[attr] }
          column_names << attr.to_sym
        end
      end

      ## ActiveRecord like APIs

      delegate :first, :last, :order, :pluck, to: :all
      alias_method :take, :first

      def primary_key
        "id"
      end

      def column_names
        @_column_names ||= [:id]
      end

      def all
        collection!(query.all)
      end

      def find(ids)
        if records = find_by_ids(ids).presence
          ids.is_a?(Array) ? collection!(records) : records.first
        else
          raise not_found(id: ids)
        end
      end

      def find_by(conditions)
        if conditions.is_a?(Hash)
          conditions.symbolize_keys!
          if id = conditions.delete(:id)
            records = find_by_ids(id)
            case
            when records.empty? then nil
            when conditions.empty? then records.first
            else
              records.detect {|record|
                conditions.all? {|k, v| record.public_send(k) == v }
              }
            end
          else
            all.find_by(conditions.dup)
          end
        else
          find_by_ids(conditions).first
        end
      end

      def find_by!(conditions)
        find_by(conditions.dup) || (raise not_found(conditions))
      end

      def where(conditions)
        conditions.symbolize_keys!
        if id = conditions.delete(:id)
          records = find_by_ids(id)
          if conditions.empty?
            collection!(records)
          else
            collection!(records.select {|record|
              conditions.all? {|k, v| record.public_send(k) == v }
            })
          end
        else
          all.where(conditions.dup)
        end
      end

      def create(attrs = {})
        record = new(attrs)
        record.save
        record
      end
      alias_method :create!, :create

      ## Query APIs

      delegate :find_by_ids, :insert, to: :query
      delegate :count, :ids, :delete_all, to: :query
      alias_method :destroy_all, :delete_all

      def exists?(obj)
        if _id = id_from(obj)
          query.exists?(_id)
        else
          false
        end
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
        def collection!(records)
          records.is_a?(Array) ? Collection.new(self, records) : records
        end

        def not_found(params)
          RecordNotFound.new(self, params)
        end

        def id_from(obj)
          obj.is_a?(self) ? obj.id : obj.to_i
        end
    end

    def initialize(params = {})
      params = params.with_indifferent_access
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
      self.class.insert(self)
    end
    alias_method :save!, :save

    def delete
      self.class.delete(self)
    end
    alias_method :destroy, :delete

    def attributes
      @_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def attribute=(attr, value)
      attributes[attr.to_sym] = value
    end

    def attribute?(attr)
      attributes[attr.to_sym].present?
    end
  end
end
