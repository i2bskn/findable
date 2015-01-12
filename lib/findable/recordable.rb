module Findable
  module Recordable
    extend ActiveSupport::Concern
    include Serializer

    included do
      include ActiveModel::AttributeMethods

      attribute_method_suffix "="
      attribute_method_suffix "?"
    end

    module ClassMethods
      def field(attr, options={})
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
            define_method attr do
              attributes[attr]
            end
          end
        end
    end

    def initialize(params={})
      params = deserialize(params) if params.is_a?(String)
      params.symbolize_keys!
      params.keys.each {|attr| self.class.field(attr) }
      @_attributes = params
    end

    def id
      attributes[:id].presence || nil
    end
    # alias_method :quoted_id, :id

    def id=(_id)
      attributes[:id] = _id
    end

    def save
      self.class.insert(self)
    end
    alias_method :save!, :save

    def new_record?
      id ? !self.class.exists?(self) : true
    end

    def persisted?
      !new_record?
    end

    def to_json(methods: nil)
      _attrs = attributes.dup
      _attrs.merge!(methods.to_sym => self.send(methods)) if methods
      serialize(_attrs)
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

