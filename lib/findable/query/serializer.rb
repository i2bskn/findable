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
      def deserialize(raw_data, klass = nil)
        objects = Array(raw_data).compact.map {|data|
          object = @serializer.load(data)
          object = object.with_indifferent_access if object.is_a?(Hash)
          klass ? klass.new(object) : object
        }
        raw_data.is_a?(String) ? objects.first : objects
      end
    end
  end
end
