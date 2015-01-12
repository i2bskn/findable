module Findable
  module Namespace
    extend ActiveSupport::Concern

    module ClassMethods
      def info_key
        namepace[:info]
      end

      def data_key
        namespace[:data]
      end

      private
        def namespace
          %i(info data).each_with_object({}) do |name, obj|
            obj[name] = [self.model_name.plural, name].join(":")
          end
        end
    end
  end
end

