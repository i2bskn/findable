require "spec_helper"

describe ActiveModel::Lint::Tests do
  before { class Tag < Findable::Base; end }
  after { Object.send(:remove_const, "Tag") }
  let(:tag) { Tag.new }

  context "#test_to_key" do
    it "The model should respond to to_key" do
      expect(tag).to respond_to(:to_key)
    end

    it "to_key should return nil when `persisted?` returns false" do
      allow(tag).to receive(:persisted?).and_return(false)
      expect(tag.to_key).to be_nil
    end
  end

  context "#test_to_param" do
    it "The model should respond to to_param" do
      expect(tag).to respond_to(:to_param)
    end

    it "to_param should return nil when `persisted?` returns false" do
      allow(tag).to receive(:to_key).and_return([1])
      allow(tag).to receive(:persisted?).and_return(false)
      expect(tag.to_param).to be_nil
    end
  end

  context "#test_to_partial_path" do
    it "The model should respond to to_partial_path" do
      expect(tag).to respond_to(:to_partial_path)
    end

    it { expect(tag.to_partial_path).to be_kind_of(String) }
  end

  context "#test_persisted?" do
    it "The model should respond to persisted?" do
      expect(tag).to respond_to(:persisted?)
    end

    it "persisted?" do
      bool = tag.persisted?
      expect(bool == true || bool == false).to be_truthy
    end
  end

  context "#test_model_naming" do
    it "The model class should respond to model_name" do
      expect(tag).to respond_to(:model_name)
    end

    it { expect(Tag.model_name).to respond_to(:to_str) }
    it { expect(Tag.model_name.human).to respond_to(:to_str) }
    it { expect(Tag.model_name.singular).to respond_to(:to_str) }
    it { expect(Tag.model_name.plural).to respond_to(:to_str) }

    it { expect(tag).to respond_to(:model_name) }
    it { expect(tag.model_name).to eq(Tag.model_name) }
  end

  context "#test_errors_aref" do
    it "The model should respond to errors" do
      expect(tag).to respond_to(:errors)
    end

    it "errors#[] should return an Array" do
      expect(tag.errors[:hello]).to be_kind_of(Array)
    end
  end
end

