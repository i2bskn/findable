# =========================
# Initialize and Migrations
# =========================

# Initialize Redis
Findable::Base.query.redis.flushdb

# Initialize SQLite
ActiveRecord::Base.establish_connection({
  adapter: "sqlite3",
  database: ":memory:",
})

ActiveRecord::Migration.create_table :companies do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :stores do |t|
  t.string :name
  t.integer :company_id
end

ActiveRecord::Migration.create_table :emails do |t|
  t.string :address
  t.integer :store_id
  t.integer :user_id
end

ActiveRecord::Migration.create_table :pictures do |t|
  t.string :name
  t.integer :user_id
end

# =========================
# Model definitions
# =========================

# Model < Findable
%w(Category Product Image User).each do |class_name|
  Object.const_set(class_name, Class.new(Findable::Base))
end

# Model < ActiveRecord
%w(Company Store Email Picture).each do |class_name|
  Object.const_set(class_name, Class.new(ActiveRecord::Base))
end

ActiveRecord::Base.subclasses.each do |ar|
  ar.include Findable::Associations::ActiveRecordExt
end

# Associations
Category.has_many :products
Product.belongs_to :category
Product.has_one :image
Image.belongs_to :product

Company.has_many :stores
Store.belongs_to :company
Store.has_one :email
Email.belongs_to :store

User.belongs_to :content, polymorphic: true

User.has_many :pictures
Picture.belongs_to :user

User.has_one :email
Email.belongs_to :user

Company.has_many :users
User.belongs_to :company

Company.has_one :image
Image.belongs_to :company

# =========================
# Data import
# =========================
CategoryData = [{id: 1, name: "Book"}]
Category.query.import(CategoryData)

ProductData = [
  {id: 1, name: "book 1", category_id: 1},
  {id: 2, name: "book 2", category_id: 1},
]
Product.query.import(ProductData)

ImageData = [
  {id: 1, product_id: 1, company_id: 1},
  {id: 2, product_id: 2, company_id: 1},
]
Image.query.import(ImageData)

UserData = [
  {id: 1, name: "user 1", content_type: "Image", content_id: 1, company_id: 1},
  {id: 2, name: "user 2", content_type: "Picture", content_id: 1, company_id: 1}
]
User.query.import(UserData)

Company.create!(id: 1, name: "company 1")
Company.create!(id: 2, name: "company 2")
Store.create(id: 1, name: "store 1", company_id: 1)
Email.create!(id: 1, address: "findable@example.com", store_id: 1, user_id: 1)
Picture.create!(id: 1, name: "picture 1", user_id: 1)
Picture.create!(id: 2, name: "picture 2", user_id: 1)
