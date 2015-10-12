require "findable/schema/conversion"

module Findable
  module Schema
    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Dirty

      attribute_method_suffix "="
      attribute_method_suffix "?"
    end

    module ClassMethods
      def column_names
        @_column_names ||= [:id]
      end

      def indexes
        @_indexes ||= [:id]
      end

      def secondary_indexes
        indexes.select {|name| name != :id }
      end

      def index_defined?
        indexes.size > 1
      end

      def define_field(*args)
        options = args.extract_options!
        name = args.first
        if !public_method_defined?(name) || options.present?
          define_attribute_methods name
          conversion = Findable::Schema::Conversion.to(options[:type])
          define_method(name) { conversion.call(attributes[name.to_sym]) }
          indexes << name.to_sym if options[:index]
          column_names << name.to_sym
        end
      end
    end

    def attribute=(attr, value)
      public_send("#{attr}_will_change!")
      attributes[attr] = value
    end

    def attribute?(attr)
      attributes[attr].present?
    end
  end
end
