module Findable
  module Store
    module Namespace
      extend ActiveSupport::Concern

      module ClassMethods
        # @return [String] info key string
        def info_key
          namespace[:info]
        end

        # @return [String] data key string
        def data_key
          namespace[:data]
        end

        private
          # @return [Hash] namespace of data and info
          def namespace
            @_namespaces ||= %i(info data).each_with_object({}) {|name, obj|
              obj[name] = [self.model_name.plural, name].join(":")
            }
          end
      end
    end
  end
end

