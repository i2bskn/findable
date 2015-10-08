module Findable
  class Query
    module Namespace
      PREFIX = "findable"
      META_NAMES = %i(info index lock thread)
      AUTO_INCREMENT_KEY = :auto_increment # TODO: delete

      META_NAMES.each do |name|
        define_method([name, "key"].join("_")) { namespaces[name] }
      end

      def data_key
        @_data_key ||= [PREFIX, basename].join(":")
      end

      private
        def basename
          model.model_name.plural
        end

        # @return [Hash] namespaces
        def namespaces
          @_namespaces ||= META_NAMES.each_with_object({}) {|key, obj|
            obj[key] = [data_key, key].join(":")
          }
        end
    end
  end
end
