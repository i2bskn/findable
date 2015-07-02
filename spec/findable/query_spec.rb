require "spec_helper"

describe Findable::Query do
  include_context "TemporaryModel"
  include_context "ReadOnlyModel"

  let(:auto_increment_key) { Findable::Query::Namespace::AUTO_INCREMENT_KEY }

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

  describe "#transaction" do
  end

  describe "#auto_incremented_id" do
    context "when id is nil" do
      let!(:id) { model.query.send(:auto_incremented_id, nil) }
      let(:info_id) {
        model.query.redis.hget(model.query.info_key, auto_increment_key).to_i
      }

      it { expect(id).to be_kind_of(Integer) }
      it { expect(id).to eq(info_id) }
    end

    context "when id is not nil" do
      before { model.query.redis.hset(model.query.info_key, auto_increment_key, 10) }

      it {
        expect_any_instance_of(Redis).not_to receive(:hset)
        id = model.query.send(:auto_incremented_id, 5)
        expect(id).to eq(5)
      }

      it {
        expect_any_instance_of(Redis).to receive(:hset)
        id = model.query.send(:auto_incremented_id, 15)
        expect(id).to eq(15)
      }
    end
  end
end
