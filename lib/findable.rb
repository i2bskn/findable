require "pathname"
require "bigdecimal"

require "active_support"
require "active_support/core_ext"
require "active_model"
require "redis"
require "redis_eval"
require "msgpack"

RedisEval.config.script_paths = [File.expand_path("../findable/script", __FILE__)]

require "findable/version"
require "findable/errors"
require "findable/configuration"
require "findable/query"
require "findable/collection"
require "findable/base"
require "findable/railtie" if defined?(Rails)
