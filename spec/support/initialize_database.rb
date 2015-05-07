# Initialize Redis
Redis.current.flushdb

# Initialize SQLite
ActiveRecord::Base.establish_connection({
  adapter: "sqlite3",
  database: ":memory:",
})

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :articles do |t|
  t.string :title
  t.integer :tag_id
  t.integer :user_id
end

ActiveRecord::Migration.create_table :emails do |t|
  t.string :address
  t.integer :user_id
  t.integer :group_id
end

# Model definitions
class Group < Findable::Base; end
class Tag < Findable::Base; end
class Info < Findable::Base; end

class Article < ActiveRecord::Base; end
class User < ActiveRecord::Base; end
class Email < ActiveRecord::Base; end

# Associations
Group.has_many :tags
Group.has_one :info
Group.has_one :email
Group.belongs_to :content, polymorphic: true
Tag.belongs_to :group
Tag.belongs_to :user
Tag.has_many :articles
Info.belongs_to :group
Info.belongs_to :user
Info.belongs_to :content, polymorphic: true

[Article, User, Email].each {|ar| ar.include Findable::Associations::ActiveRecordExt }
Article.belongs_to :tag
Article.belongs_to :user
User.has_many :tags
User.has_many :articles
User.has_one :info
User.has_one :email
Email.belongs_to :user
Email.belongs_to :group

# Data import
Group.query.import([{id: 1, name: "group1", content_type: "Article", content_id: 1}])
Tag.query.import([
  {id: 1, name: "tag1", group_id: 1, user_id: 1},
  {id: 2, name: "tag2", group_id: 1, user_id: 1},
])
Info.query.import([{id: 1, group_id: 1, user_id: 1, content_type: "Group", content_id: 1}])
Article.create!(id: 1, title: "some title", tag_id: 1, user_id: 1)
User.create!(id: 1, name: "some user")
Email.create!(id: 1, address: "some@example.com", user_id: 1, group_id: 1)

