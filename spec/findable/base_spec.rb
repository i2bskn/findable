require "spec_helper"

describe Findable::Base do
  include_context "TemporaryModel"
  include_context "ReadModel"

  describe ".primary_key" do
    it { expect(model.primary_key).to eq("id") }
  end

  describe ".column_names" do
    it { expect(model.column_names).to eq([:id, :name]) }
  end

  describe ".all" do
    it { expect(read_model.all).to be_kind_of(Array) }
    it { expect(read_model.all.size).to eq(1) }
  end

  describe ".find" do
    it { expect(read_model.find(id)).to be_kind_of(read_model) }
    it { expect(read_model.find([id])).to be_kind_of(Array) }
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
    it { expect(read_model.where(id: id)).to be_kind_of(Array) }
    it { expect(read_model.where(id: id).first).to be_kind_of(read_model) }
    it { expect(read_model.where(id: invalid_id)).to be_empty }
    it { expect(read_model.where(id: id, name: name)).to be_kind_of(Array) }
    it { expect(read_model.where(id: id, name: name).first).to be_kind_of(read_model) }
    it { expect(read_model.where(id: invalid_id, name: name)).to be_empty }
    it { expect(read_model.where(name: name)).to be_kind_of(Array) }
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
end

