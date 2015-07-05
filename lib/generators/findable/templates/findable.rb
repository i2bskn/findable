Findable.configure do |config|
  # Redis connection setting. Default is `Redis.current`.
  # config.redis_options = {host: "localhost", port: 6379, db: 2}

  # Serializer setting. Default is JSON.
  # It can be specify an object with the following methods.
  #   * dump - To string from an object.
  #   * load - To object from a string.
  # config.serializer = Oj

  # Directory of stored seed files.
  config.seed_dir = Rails.root.join("db", "findable_seeds")

  # Seed file of Findable.
  config.seed_file = Rails.root.join("db", "findable_seeds.rb")
end
