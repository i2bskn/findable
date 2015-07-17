# Seed file of Findable

# Require seed support module
require "findable/seed"

# Target seed files.
# Run all in the case of `nil`.
# Example of if you want to run some only.
# seed_files = ["products", "customers"] #=> Only products.yml and customers.yml
seed_files = nil

# Execute
Findable::Seed.target_files(seed_files: seed_files).each(&:bootstrap!)
