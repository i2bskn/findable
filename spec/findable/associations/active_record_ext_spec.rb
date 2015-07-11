require "spec_helper"

describe Findable::Associations::ActiveRecordExt do
  # ActiveRecord models
  let(:user) { User.first }
  let(:user2) { User.second }
  let(:status) { Status.take }

  # Findable models
  let(:image) { Image.take }

  describe "#has_many" do
    it { expect(user.purchase_histories).to be_kind_of(Findable::Collection) }
    it { expect(user.purchase_histories.first).to be_kind_of(PurchaseHistory) }
    it { expect(user.comments).to be_kind_of(ActiveRecord::Relation) }
    it { expect(user.comments.first).to be_kind_of(Comment) }
  end

  describe "#has_one" do
    it { expect(user.image).to be_kind_of(Image) }
    it { expect(user.status).to be_kind_of(Status) }
  end

  describe "#belongs_to" do
    it { expect(image.user).to be_kind_of(User) }
    it { expect(status.user).to be_kind_of(User) }
    it {
      image.user = user2
      expect(image).to have_attributes(user_id: user2.id)
    }
  end
end
