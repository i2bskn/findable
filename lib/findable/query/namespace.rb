module Findable
  class Query
    module Namespace
      PREFIX = "findable".freeze
      KEY_NAMES = %i(info data lock index).freeze
      AUTO_INCREMENT_KEY = :auto_increment

      KEY_NAMES.each do |name|
        define_method([name, "key"].join("_")) { namespaces[name] }
      end

      def thread_key
        [PREFIX, basename].join("_")
      end

      private
        def basename
          model.model_name.plural
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
