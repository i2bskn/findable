module Findable
  class FindableError < StandardError; end
  class RecordNotFound < FindableError; end

  class ModelNotFound < FindableError
    def initialize(model_name)
      super("#{model_name} not found!")
    end
  end
end

