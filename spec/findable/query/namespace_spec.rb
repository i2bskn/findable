require "spec_helper"

describe Findable::Query::Namespace do
  include_context "TemporaryModel"

  before do
    QueryEx = Class.new
    QueryEx.include Findable::Query::Namespace
  end

  after { Object.send(:remove_const, "QueryEx") }

  let(:namespace) { Findable::Query::Namespace }
  let(:query) { QueryEx.new(model) }

  describe "Method definitions of various keys" do
    it {
      namespace::KEY_NAMES.each do |name|
        expect(query.public_send("#{name}_key")).to be_kind_of(String)
        expect(query.public_send("#{name}_key")).to start_with(namespace::PREFIX)
      end
    }
  end

  describe "#initialize" do
    it { expect(query.instance_eval { @_model }).to eq(model) }
  end

  describe "#thread_key" do
    it { expect(query.thread_key).to be_kind_of(String) }
    it { expect(query.thread_key).to start_with(namespace::PREFIX) }
  end

  describe "#basename" do
    it { expect(query.send(:basename)).to eq("sizes") }
  end

  describe "#namespaces" do
    it { expect(query.send(:namespaces)).to be_kind_of(Hash) }
    it {
      expect(query.send(:namespaces)).to satisfy {|hash|
        namespace::KEY_NAMES.all? {|key| hash.has_key?(key) }
      }
    }
    it {
      query.send(:namespaces)
      expect(query).not_to receive(:basename)
      query.send(:namespaces)
    }
  end
end

