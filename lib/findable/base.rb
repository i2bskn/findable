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

      def primary_key
        "id"
      end

      def column_names
        @_column_names ||= [:id]
      end

      def find(ids)
        if records = find_by_ids(ids).presence
          ids.is_a?(Array) ? records : records.first
        else
          raise RecordNotFound.new(self, id: ids)
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
            all.detect {|record|
              conditions.all? {|k, v| record.public_send(k) == v }
            }
          end
        else
          find_by_ids(conditions).first
        end
      end

      def find_by!(conditions)
        find_by(conditions.dup) || (raise RecordNotFound.new(self, conditions))
      end

      def where(conditions)
        conditions.symbolize_keys!
        if id = conditions.delete(:id)
          records = find_by_ids(id)
          if conditions.empty?
            records
          else
            records.select {|record|
              conditions.all? {|k, v| record.public_send(k) == v }
            }
          end
        else
          all.select {|record|
            conditions.all? {|k, v| record.public_send(k) == v }
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
          self.all.public_send(m)
        end
      end

      ## Query APIs

      delegate :find_by_ids, :all, to: :query
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
      @_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
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
