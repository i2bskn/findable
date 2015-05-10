require "spec_helper"

describe Findable::Associations::ActiveRecordExt do
  let(:company) { Company.first }
  let(:store) { Store.first }
  let(:email) { Email.first }
  let(:user) { User.first }

  describe "#has_many" do
    it { expect(company.users).to be_kind_of(Array) }
    it { expect(company.users.first).to be_kind_of(User) }
    it { expect(company.stores).to be_kind_of(ActiveRecord::Relation) }
    it { expect(company.stores.first).to be_kind_of(Store) }
  end

  describe "#has_one" do
    it { expect(company.image).to be_kind_of(Image) }
    it { expect(store.email).to be_kind_of(Email) }
  end

  describe "#belongs_to" do
    it { expect(email.user).to be_kind_of(User) }
    it { expect(store.company).to be_kind_of(Company) }
    it {
      email.user = user
      expect(email.user_id).to eq(user.id)
    }
  end
end

