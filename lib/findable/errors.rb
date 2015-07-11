module Findable
  class FindableError < StandardError; end

  class RecordNotFound < FindableError
    def initialize(model, params)
      params.symbolize_keys! if params.is_a?(Hash)
      super("Couldn't find #{model.model_name.name} with #{params.inspect}")
    end
  end

  class NotActiveRecord < FindableError
    def initialize(model)
      super("#{model.model_name.name} class is not ActiveRecord")
    end
  end

  class LockTimeout < FindableError; end
end
