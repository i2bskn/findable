module Findable
  module Schema
    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods

      attribute_method_suffix "="
      attribute_method_suffix "?"
    end

    module ClassMethods
      def primary_key
        "id"
      end

      def field(attr, options = {})
        options.symbolize_keys!
        define_accessor(attr.to_sym, options)
      end

      def fields(*args)
        options = args.extract_options!
        args.each {|arg| field(arg, options) }
      end

      private
        def define_accessor(attr, options)
          unless public_method_defined?(attr)
            define_attribute_methods attr
            define_method(attr) { attributes[attr] }
          end
        end
    end

    def initialize(params = {})
      params = deserialize(params) if params.is_a?(String)
      params.symbolize_keys!
      params.keys.each {|attr| self.class.field(attr) }
      @_attributes = params
    end

    def id
      attributes[:id].presence
    end
    alias_method :quoted_id, :id

    def id=(_id)
      attributes[:id] = _id
    end

    def hash
      id.hash
    end

    def attributes
      @_attributes ||= {}
    end

    private
      def attribute=(attr, val)
        attributes[attr.to_sym] = val
      end

      def attribute?(attr)
        attributes[attr.to_sym].present?
      end
  end
end

