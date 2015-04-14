module Findable
  module Associations
    def has_many(name, scope = nil, options = {})
      super unless _define_association_methods(:has_many, name, options)
    end

    def has_one(name, scope = nil, options = {})
      super unless _define_association_methods(:has_one, name, options)
    end

    def belongs_to(name, scope = nil, options = {})
      super unless _define_association_methods(:belongs_to, name, options)
    end

    private
      def _define_association_methods(association_type, name, options)
        model = _model_for(name, options, true)
        if _findable?(model) || _findable?(self)
          self.send("_define_findable_#{association_type}", name, options, model)
        else
          false
        end
      end

      def _model_for(name, options, _raise = false)
        class_name = _class_name_for(name, options)
        begin
          class_name.constantize
        rescue => e
          _raise ? (raise Findable::ModelNotFound.new(class_name)) : nil
        end
      end

      def _class_name_for(name, options)
        options[:class_name].presence || name.to_s.classify
      end

      def _foreign_key_for(name, options)
        options[:foreign_key].presence || name.to_s.foreign_key
      end

      def _findable?(model)
        model.ancestors.include?(Findable::Base)
      end

      def _define_findable_has_many(name, options, model)
        foreign_key = _foreign_key_for(self.model_name.name, options)

        define_method name do
          model.where(foreign_key.to_sym => id)
        end
      end

      def _define_findable_has_one(name, options, model)
        foreign_key = _foreign_key_for(self.model_name.name, options)

        define_method name do
          model.find_by(foreign_key.to_sym => id)
        end
      end

      def _define_findable_belongs_to(name, options, model)
        foreign_key = _foreign_key_for(name, options)

        if options[:polymorphic]
          define_method name do
            self.send("#{name}_type").constantize.find(self.send(foreign_key))
          end
        else
          define_method name do
            model.find(self.send(foreign_key))
          end
        end

        define_method "#{name}=" do |record|
          self.send("#{foreign_key}=", record.try(:id))
        end
      end
  end
end

