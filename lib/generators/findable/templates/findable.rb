Findable.configure do |config|
  # Redis connection setting. (default: `Redis.current`)
  # config.redis_options = {host: "localhost", port: 6379, db: 2}

  # Directory of stored seed files.
  config.seed_dir = Rails.root.join("db", "findable_seeds")

  # Seed file of Findable.
  config.seed_file = Rails.root.join("db", "findable_seeds.rb")
end

