require "spec_helper"

describe Findable::Associations do
  let(:group) { Group.first }
  let(:info) { Info.first }
  let(:tag) { Tag.first }

  describe "#has_many" do
    it { expect(group.tags.map(&:id).sort).to eq(Tag.all.map(&:id).sort) }
  end

  describe "#has_one" do
    it { expect(group.info.id).to eq(info.id) }
  end

  describe "#belongs_to" do
    it { expect(tag.group.id).to eq(group.id) }
  end
end

