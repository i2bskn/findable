module Findable
  class Query
    module Namespace
      PREFIX = "findable"
      META_NAMES = %i(info lock thread)
      DELIMITER = ":"

      META_NAMES.each do |name|
        define_method([name, "key"].join("_")) { namespaces[name] }
      end

      def data_key
        @_data_key ||= [PREFIX, basename].join(DELIMITER)
      end

      def index_key(column)
        @_index_base ||= [data_key, "index"].join(DELIMITER)
        [@_index_base, column].join(DELIMITER)
      end

      private
        def basename
          model.model_name.plural
        end

        # @return [Hash] namespaces
        def namespaces
          @_namespaces ||= META_NAMES.each_with_object({}) {|key, obj|
            obj[key] = [data_key, key].join(DELIMITER)
          }
        end
    end
  end
end
