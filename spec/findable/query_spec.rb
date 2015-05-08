require "spec_helper"

describe Findable::Query do
  include_context "TemporaryModel"
  let(:read_model) { Group }
  let(:name) { "some text" }

  describe "#data" do
    it { expect(read_model.query.data).to be_kind_of(Array) }
    it { expect(read_model.query.data.size).to eq(1) }
  end

  describe "#ids" do
    it { expect(read_model.query.ids).to be_kind_of(Array) }
    it { expect(read_model.query.ids).to eq([1]) }
  end

  describe "#count" do
    it { expect(read_model.query.count).to eq(1) }
  end

  describe "#find_by_ids" do
    let(:raw_value) { read_model.query.find_by_ids(1) }
    let(:loaded_value) { Oj.load(raw_value.first) }

    it { expect(raw_value).to be_kind_of(Array) }
    it { expect(raw_value.first).to be_kind_of(String) }
    it { expect(loaded_value[:id]).to eq(1) }
  end

  describe "#exists?" do
    it { expect(read_model.exists?(1)).to be_truthy }
    it { expect(read_model.exists?(2)).to be_falsey }
  end

  describe "#insert" do
    it { expect(model.query.insert(name: name)).to be_kind_of(Hash) }
    it { expect(model.query.insert(name: name)[:id]).not_to be_nil }
    it { expect(model.query.insert(name: name)[:name]).to eq(name) }
    it {
      expect {
        model.query.insert(name: name)
      }.to change { model.query.count }.by(1)
    }
  end

  describe "#import" do
  end

  describe "#delete" do
    let!(:params) { model.query.insert(name: name) }

    it {
      expect {
        model.query.delete(params[:id])
      }.to change { model.query.count }.by(-1)
    }
  end

  describe "#delete_all" do
    before {
      model.query.insert(name: name)
      model.query.delete_all
    }

    it { expect(model.query.redis.exists(model.query.data_key)).to be_falsey }
    it { expect(model.query.redis.exists(model.query.info_key)).to be_falsey }
  end
end

