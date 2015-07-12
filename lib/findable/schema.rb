require "findable/schema/conversion"

module Findable
  module Schema
    extend ActiveSupport::Concern

    included do
      attribute_method_suffix "="
      attribute_method_suffix "?"
    end

    module ClassMethods
      def column_names
        @_column_names ||= [:id]
      end

      def define_field(*args)
        options = args.extract_options!
        name = args.first
        if !public_method_defined?(name) || options.present?
          define_attribute_methods name
          conversion = Conversion.for(options[:type])
          define_method(name) { conversion.call(attributes[name.to_sym]) }
          column_names << name.to_sym
        end
      end
    end

    def attribute=(attr, value)
      attributes[attr] = value
    end

    def attribute?(attr)
      attributes[attr].present?
    end
  end
end
