require "spec_helper"

describe Findable::Associations do
  # Findable models
  let(:category) { Category.find(CategoryData.first[:id]) }
  let(:category2) { Category.find(CategoryData.second[:id]) }
  let(:product) { Product.take }
  let(:image) { Image.find(ImageData.first[:id]) }
  let(:image2) { Image.find(ImageData.second[:id]) }
  let(:cart) { Cart.take }

  describe "#has_many" do
    it { expect(category.products).to be_kind_of(Findable::Collection) }
    it { expect(category.products.first).to be_kind_of(Product) }
    it { expect(product.comments).to be_kind_of(ActiveRecord::Relation) }
    it { expect(product.comments.first).to be_kind_of(Comment) }
  end

  describe "#has_one" do
    it { expect(product.image).to be_kind_of(Image) }
    it { expect(cart.user).to be_kind_of(User) }
  end

  describe "#belongs_to" do
    it { expect(product.category).to be_kind_of(Category) }
    it { expect(image.user).to be_kind_of(User) }
    it { expect(image.content).to be_kind_of(image.content_type.constantize) }
    it { expect(image2.content).to be_kind_of(image2.content_type.constantize) }
    it {
      product.category = category2
      expect(product).to have_attributes(category_id: category2.id)
    }
  end
end
