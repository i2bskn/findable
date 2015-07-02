module Findable
  class Query
    module Namespace
      PREFIX = "findable".freeze
      KEY_NAMES = %i(info data lock index).freeze
      AUTO_INCREMENT_KEY = :auto_increment

      def initialize(model)
        @_model = model
      end

      KEY_NAMES.each do |key|
        define_method([key, "key"].join("_")) { namespaces[key] }
      end

      def thread_key
        [PREFIX, basename].join("_")
      end

      private
        def basename
          @_model.model_name.plural
        end

        # @return [Hash] namespaces
        def namespaces
          @_namespaces ||= KEY_NAMES.each_with_object({}) {|key, obj|
            obj[key] = [PREFIX, basename, key].join(":")
          }
        end
    end
  end
end
