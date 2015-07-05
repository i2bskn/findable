module Findable
  module Inspection
    extend ActiveSupport::Concern

    module ClassMethods
      def inspect
        case
        when self == Findable::Base
          super
        else
          "#{self}(#{column_names.map(&:inspect).join(', ')})"
        end
      end
    end

    def inspect
      _attributes = self.class.column_names.each_with_object([]) {|name, obj|
        obj << "#{name}: #{public_send(name).inspect}"
      }.join(",\s")
      "#<#{self.class} #{_attributes}>"
    end
  end
end
