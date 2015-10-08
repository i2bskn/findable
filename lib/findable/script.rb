require "findable/query/connection"

module Findable
  class Script
    include Findable::Query::Connection

    BASE_PATH = File.expand_path("../script", __FILE__)
    NAMES = Pathname.glob(File.join(BASE_PATH, "*.lua")).map {|f| f.basename(".*").to_s }

    attr_reader :name, :path, :script, :sha

    class << self
      def scripts
        @scripts ||= {}
      end

      private
        def method_missing(name, *args, &block)
          define_singleton_method(name) do |*a, &b|
            name = name.to_s
            scripts[name] ||= new(name)
          end

          send(name, *args, &block)
        end

        def respond_to_missing?(name, include_private = false)
          name.to_s.in? NAMES
        end
    end

    def initialize(name)
      @name = name
      @path = File.join(BASE_PATH, "#{name}.lua")
      @script = File.read(@path)
      @sha = Digest::SHA1.hexdigest(@script)
    end

    def execute(keys, argv)
      redis.evalsha(sha, Array(keys), Array(argv))
    rescue Redis::CommandError => e
      if e.message =~ /NOSCRIPT/
        redis.eval(script, Array(keys), Array(argv))
      else
        raise
      end
    end
  end
end
