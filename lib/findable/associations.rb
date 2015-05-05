require "findable/associations/utils"

module Findable
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(*args)
        name, options = Utils.parse_args(args)
        model = Utils.model_for(name, collection: true, **options)
        foreign_key = options[:foreign_key].presence || model_name.name.foreign_key

        define_method(name) do
          model.where(foreign_key => public_send(self.class.primary_key))
        end
      end

      def has_one(*args)
        name, options = Utils.parse_args(args)
        model = Utils.model_for(name, **options)
        foreign_key = options[:foreign_key].presence || model_name.name.foreign_key

        define_method(name) do
          model.find_by(foreign_key => public_send(self.class.primary_key))
        end
      end

      def belongs_to(*args)
        name, options = Utils.parse_args(args)
        model = Utils.model_for(name, safe: true, **options)
        foreign_key = options[:foreign_key].presence || name.to_s.foreign_key

        if options[:polymorphic]
          define_method(name) do
            public_send("#{name}_type").constantize.find(public_send(foreign_key))
          end
        else
          define_field(foreign_key)

          define_method(name) do
            model.find_by(model.primary_key => public_send(foreign_key))
          end

          define_method("#{name}=") do |value|
            attributes[foreign_key.to_sym] = value ? value.public_send(model.primary_key) : nil
          end
        end
      end
    end
  end
end

