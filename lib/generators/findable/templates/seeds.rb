# Seed file of Findable

# Require seed support module
require "findable/seed"

# Path to the reading of the seed.
seed_dir = File.expand_path("../findable_seeds", __FILE__)

# Target seed files.
# Run all in the case of `nil`.
# Example of if you want to run some only.
# seed_files = ["products", "customers"] #=> Only products.yml and customers.yml
seed_files = nil

# Execute
Findable::Seed.target_files(seed_dir, seed_files).each {|seed| seed.bootstrap! }

