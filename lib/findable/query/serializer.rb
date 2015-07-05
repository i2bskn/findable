module Findable
  class Query
    class Serializer
      def initialize(serializer = nil)
        @serializer = serializer || Findable.config.serializer
      end

      def serialize(object)
        @serializer.dump(object)
      end

      # @params raw_data [String] Serialized string
      # @params raw_data [Array<String>] Array of serialized string
      # @return [ActiveSupport::HashWithIndifferentAccess]
      # @return [Array<ActiveSupport::HashWithIndifferentAccess>]
      def deserialize(raw_data)
        objects = Array(raw_data).map {|data|
          object = @serializer.load(data)
          object.is_a?(Hash) ? object.with_indifferent_access : object
        }
        raw_data.is_a?(String) ? objects.first : objects
      end
    end
  end
end
