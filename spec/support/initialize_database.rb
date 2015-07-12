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

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
  t.integer :cart_id
  t.string :content_type
  t.integer :content_id
end

ActiveRecord::Migration.create_table :statuses do |t|
  t.integer :total_payments
  t.integer :user_id
end

ActiveRecord::Migration.create_table :comments do |t|
  t.text :body
  t.integer :user_id
  t.integer :product_id
end

ActiveRecord::Migration.create_table :pictures do |t|
  t.string :name
end

# =========================
# Model definitions
# =========================

# Model < Findable
%w(Category Product Image PurchaseHistory Cart).each do |class_name|
  Object.const_set(class_name, Class.new(Findable::Base))
end

# Model < ActiveRecord
%w(User Comment Status Picture).each do |class_name|
  Object.const_set(class_name, Class.new(ActiveRecord::Base))
end

ActiveRecord::Base.subclasses.each do |ar|
  ar.include Findable::Associations::ActiveRecordExt
end

# Associations (Findable <=> Findable)
Category.has_many :products
Product.belongs_to :category
Product.has_one :image
Image.belongs_to :product

# Associations (ActiveRecord <=> ActiveRecord)
User.has_many :comments
User.has_one :status
Comment.belongs_to :user
Status.belongs_to :user

# Associations (Findable <=> ActiveRecord)
Product.has_many :comments
Comment.belongs_to :product

Cart.has_one :user
User.belongs_to :cart

User.has_many :purchase_histories
PurchaseHistory.belongs_to :user

User.has_one :image
Image.belongs_to :user

# Polymorphic association
User.belongs_to :content, polymorphic: true
Image.belongs_to :content, polymorphic: true

# =========================
# Data import
# =========================
CategoryData = [
  {id: 1, name: "Book"},
  {id: 2, name: "Computer"},
]
Category.query.import(CategoryData)

ProductData = [
  {id: 1, name: "book1", category_id: 1},
  {id: 2, name: "book2", category_id: 1},
]
Product.query.import(ProductData)

ImageData = [
  {id: 1, product_id: 1, user_id: 1, content_type: "User", content_id: 1},
  {id: 2, product_id: 2, user_id: 2, content_type: "Category", content_id: 1},
]
Image.query.import(ImageData)

CartData = [{id: 1}, {id: 2}]
Cart.query.import(CartData)

Picture.create(name: "example.jpg")
User.create(name: "user1", content_type: "Picture", content_id: Picture.first.id, cart_id: CartData.first[:id])
User.create(name: "user2", content_type: "Image", content_id: Image.first.id, cart_id: CartData.second[:id])
User.all.each do |user|
  user.create_status!(total_payments: rand(100_000))
  user.comments.create!(body: "some comment", product_id: Product.take.id)
end

User.all.each do |user|
  PurchaseHistory.create(user_id: user.id)
end
