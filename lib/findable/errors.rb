module Findable
  class FindableError < StandardError; end
  class RecordNotFound < FindableError; end
end

