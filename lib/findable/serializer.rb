module Findable
  module Serializer
    def serialize(obj)
      Oj.dump(obj)
    end

    def deserialize(string)
      Oj.load(string)
    end
  end
end

