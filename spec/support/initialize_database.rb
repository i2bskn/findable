# Initialize Redis
Redis.current.flushdb

# Initialize SQLite
ActiveRecord::Base.establish_connection({
  adapter: "sqlite3",
  database: ":memory:",
})

ActiveRecord::Migration.create_table :articles do |t|
  t.string :title
  t.integer :tag_id
end

# Model definitions
class Group < Findable::Base; end
class Tag < Findable::Base; end
class Info < Findable::Base; end

class Article < ActiveRecord::Base; end

# Associations
Group.has_many :tags
Group.has_one :info
Tag.belongs_to :group
Tag.has_many :article
Info.belongs_to :group

[Article].each {|ar| ar.include Findable::Associations::ActiveRecordExt }
Article.belongs_to :tag

# Data import
Group.query.import([{id: 1, name: "group1"}])
Tag.query.import([
  {id: 1, name: "tag1", group_id: 1},
  {id: 2, name: "tag2", group_id: 1},
])
Info.query.import([{id: 1, group_id: 1}])
Article.create!(id: 1, title: "some title", tag_id: 1)

