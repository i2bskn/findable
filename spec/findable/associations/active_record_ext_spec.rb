require "spec_helper"

describe Findable::Associations::ActiveRecordExt do
  let(:article) { Article.first }
  let(:user) { User.first }
  let(:email) { Email.first }

  describe "#has_many" do
    it { expect(user.tags).to be_kind_of(Array) }
    it { expect(user.tags.first).to be_kind_of(Tag) }
    it { expect(user.articles).to be_kind_of(ActiveRecord::Relation) }
    it { expect(user.articles.first).to be_kind_of(Article) }
  end

  describe "#has_one" do
    it { expect(user.info).to be_kind_of(Info) }
    it { expect(user.email).to be_kind_of(Email) }
  end

  describe "#belongs_to" do
    it { expect(article.tag).to be_kind_of(Tag) }
    it { expect(email.user).to be_kind_of(User) }
  end
end

