require "spec_helper"

describe Findable::Associations do
  let(:category) { Category.first }
  let(:product) { Product.first }
  let(:image) { Image.first }
  let(:user) { User.find(UserData.first[:id]) }
  let(:user2) { User.find(UserData.last[:id]) }
  let(:other_company) { Company.last }

  describe "#has_many" do
    it { expect(category.products).to be_kind_of(Array) }
    it { expect(category.products.first).to be_kind_of(Product) }
    it { expect(user.pictures).to be_kind_of(ActiveRecord::Relation) }
    it { expect(user.pictures.first).to be_kind_of(Picture) }
  end

  describe "#has_one" do
    it { expect(product.image).to be_kind_of(Image) }
    it { expect(user.email).to be_kind_of(Email) }
  end

  describe "#belongs_to" do
    it { expect(product.category).to be_kind_of(Category) }
    it { expect(user.company).to be_kind_of(Company) }
    it { expect(user.content).to be_kind_of(Image) }
    it { expect(user2.content).to be_kind_of(Picture) }
    it {
      user.company = other_company
      expect(user).to have_attributes(company_id: other_company.id)
    }
  end
end

