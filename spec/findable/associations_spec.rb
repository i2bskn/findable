require "spec_helper"

describe Findable::Associations do
  let(:group) { Group.first }
  let(:info) { Info.first }
  let(:tag) { Tag.first }

  describe "#has_many" do
    it { expect(group.tags).to be_kind_of(Array) }
    it { expect(group.tags.first).to be_kind_of(Tag) }
    it { expect(tag.articles).to be_kind_of(ActiveRecord::Relation) }
    it { expect(tag.articles.first).to be_kind_of(Article) }
  end

  describe "#has_one" do
    it { expect(group.info).to be_kind_of(Info) }
    it { expect(group.email).to be_kind_of(Email) }
  end

  describe "#belongs_to" do
    it { expect(tag.group).to be_kind_of(Group) }
    it { expect(tag.user).to be_kind_of(User) }
    it { expect(group.content).to be_kind_of(Article) }
    it { expect(info.content).to be_kind_of(Group) }
    it {
      other_user = User.create!(name: "other user")
      tag.user = other_user
      expect(tag).to have_attributes(user_id: other_user.id)
    }
  end
end

