module Findable
  class FindableError < StandardError; end

  class RecordNotFound < FindableError
    def initialize(model, params)
      params.symbolize_keys! if params.is_a?(Hash)
      super("Couldn't find #{model.model_name.name} with #{params.inspect}")
    end
  end

  class ModelNotFound < FindableError
    def initialize(model_name)
      super("#{model_name} not found.")
    end
  end
end

