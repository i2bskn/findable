module Findable
  module Serializer
    def serialize(string)
      Oj.dump(string)
    end

    def deserialize(string)
      Oj.load(string)
    end
  end
end

