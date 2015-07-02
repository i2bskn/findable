module Findable
  module Associations
    module ActiveRecordExt
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(*args)
          name, options = Utils.parse_args(args)
          model = Utils.model_for(name, collection: true, safe: true, **options)

          if model && model < Findable::Base
            foreign_key = options[:foreign_key].presence || model_name.name.foreign_key

            define_method(name) do
              model.where(foreign_key => public_send(self.class.primary_key))
            end

            Utils.add_reflection(:has_many, name.to_sym, options, self)
          else
            super
          end
        end

        def has_one(*args)
          name, options = Utils.parse_args(args)
          model = Utils.model_for(name, safe: true, **options)

          if model && model < Findable::Base
            foreign_key = options[:foreign_key].presence || model_name.name.foreign_key

            define_method(name) do
              model.find_by(foreign_key => public_send(self.class.primary_key))
            end

            Utils.add_reflection(:has_one, name.to_sym, options, self)
          else
            super
          end
        end

        def belongs_to(*args)
          name, options = Utils.parse_args(args)
          model = Utils.model_for(name, safe: true, **options)

          if model && model < Findable::Base
            foreign_key = options[:foreign_key].presence || name.to_s.foreign_key

            define_method(name) do
              model.find_by(model.primary_key => public_send(foreign_key))
            end

            define_method("#{name}=") do |value|
              value = value ? value.public_send(model.primary_key) : nil
              public_send("#{foreign_key}=", value)
            end

            Utils.add_reflection(:belongs_to, name.to_sym, options, self)
          else
            super
          end
        end
      end
    end
  end
end
