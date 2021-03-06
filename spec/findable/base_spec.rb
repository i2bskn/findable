require "spec_helper"

describe Findable::Base do
  include_context "TemporaryModel"
  include_context "ReadOnlyModel"

  describe ".primary_key" do
    it { expect(model.primary_key).to eq("id") }
  end

  describe ".column_names" do
    it { expect(model.column_names).to eq([:id, :name]) }
  end

  describe ".all" do
    it { expect(read_model.all).to be_kind_of(Findable::Collection) }
    it { expect(read_model.all.size).to eq(CategoryData.size) }
  end

  describe ".find" do
    it { expect(read_model.find(id)).to be_kind_of(read_model) }
    it { expect(read_model.find([id])).to be_kind_of(Findable::Collection) }
    it {
      expect {
        read_model.find(invalid_id)
      }.to raise_error(Findable::RecordNotFound)
    }
  end

  describe ".find_by" do
    it { expect(read_model.find_by(id: id)).to be_kind_of(read_model) }
    it { expect(read_model.find_by(id: invalid_id)).to be_nil }
    it { expect(read_model.find_by(id: id, name: name)).to be_kind_of(read_model) }
    it { expect(read_model.find_by(id: id, name: invalid_name)).to be_nil }
    it { expect(read_model.find_by(name: name)).to be_kind_of(read_model) }
    it { expect(read_model.find_by(name: invalid_name)).to be_nil }
    it { expect(read_model.find_by(id)).to be_kind_of(read_model) }
    it { expect(read_model.find_by(invalid_id)).to be_nil }
  end

  describe ".find_by!" do
    it {
      expect {
        read_model.find_by!(id: id)
      }.not_to raise_error
    }
    it {
      expect {
        read_model.find_by!(id: invalid_id)
      }.to raise_error(Findable::RecordNotFound)
    }
  end

  describe ".where" do
    it { expect(read_model.where(id: id)).to be_kind_of(Findable::Collection) }
    it { expect(read_model.where(id: id).first).to be_kind_of(read_model) }
    it { expect(read_model.where(id: invalid_id)).to be_empty }
    it { expect(read_model.where(id: id, name: name)).to be_kind_of(Findable::Collection) }
    it { expect(read_model.where(id: id, name: name).first).to be_kind_of(read_model) }
    it { expect(read_model.where(id: invalid_id, name: name)).to be_empty }
    it { expect(read_model.where(name: name)).to be_kind_of(Findable::Collection) }
    it { expect(read_model.where(name: name).first).to be_kind_of(read_model) }
    it { expect(read_model.where(name: invalid_name)).to be_empty }
  end

  describe ".create" do
    it {
      expect {
        model.create(name: "example")
      }.to change { model.count }.by(1)
    }
    it { expect(model).to respond_to(:create!) }
  end

  # Query APIs
  describe ".exists?" do
    let!(:persisted_object) { model.create(name: name) }

    it { expect(model.exists?(persisted_object)).to be_truthy }
    it { expect(model.exists?(persisted_object.id)).to be_truthy }
    it { expect(model.exists?(nil)).to be_falsey }
  end

  describe ".insert" do
    let(:new_object) { model.new(name: name) }

    it {
      expect {
        model.insert(new_object)
      }.to change { model.query.count }.by(1)
    }
  end

  describe ".delete" do
    let!(:persisted_object) { model.create(name: name) }

    it {
      expect {
        model.delete(persisted_object)
      }.to change { model.query.count }.by(-1)
    }
  end

  # Instance methods
  describe "#id=" do
    it {
      instance.id = id
      expect(instance.attributes[:id]).to eq(id)
    }
  end

  describe "#hash" do
    let!(:persisted_object) { model.create(name: name) }
    it { expect(persisted_object.hash).to eq(persisted_object.id.hash) }
  end

  describe "#delete" do
    let!(:persisted_object) { model.create(name: name) }
    it {
      expect {
        persisted_object.delete
      }.to change { model.query.count }.by(-1)
    }
  end

  # Private instance methods
  describe "#attribute=" do
    before { instance.send(:attribute=, :name, "value") }
    it { expect(instance.attributes[:name]).to eq("value") }
  end

  describe "#attribute?" do
    before { instance.send(:attribute=, :name, "value") }
    it { expect(instance.send(:attribute?, :name)).to be_truthy }
  end
end
