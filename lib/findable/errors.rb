module Findable
  class FindableError < StandardError; end

  class RecordNotFound < FindableError
    def initialize(params)
      params.symbolize_keys! if params.is_a?(Hash)
      super("Can not found. condition => #{params.inspect}")
    end
  end

  class ModelNotFound < FindableError
    def initialize(model_name)
      super("#{model_name} not found.")
    end
  end
end

