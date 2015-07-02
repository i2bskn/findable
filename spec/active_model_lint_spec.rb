require "spec_helper"

describe ActiveModel::Lint::Tests do
  include_context "TemporaryModel"

  context "#test_to_key" do
    it "The model should respond to to_key" do
      expect(instance).to respond_to(:to_key)
    end

    it "to_key should return nil when `persisted?` returns false" do
      allow(instance).to receive(:persisted?).and_return(false)
      expect(instance.to_key).to be_nil
    end
  end

  context "#test_to_param" do
    it "The model should respond to to_param" do
      expect(instance).to respond_to(:to_param)
    end

    it "to_param should return nil when `persisted?` returns false" do
      allow(instance).to receive(:to_key).and_return([1])
      allow(instance).to receive(:persisted?).and_return(false)
      expect(instance.to_param).to be_nil
    end
  end

  context "#test_to_partial_path" do
    it "The model should respond to to_partial_path" do
      expect(instance).to respond_to(:to_partial_path)
    end

    it { expect(instance.to_partial_path).to be_kind_of(String) }
  end

  context "#test_persisted?" do
    it "The model should respond to persisted?" do
      expect(instance).to respond_to(:persisted?)
    end

    it "persisted?" do
      bool = instance.persisted?
      expect(bool == true || bool == false).to be_truthy
    end
  end

  context "#test_model_naming" do
    it "The model class should respond to model_name" do
      expect(instance).to respond_to(:model_name)
    end

    it { expect(model.model_name).to respond_to(:to_str) }
    it { expect(model.model_name.human).to respond_to(:to_str) }
    it { expect(model.model_name.singular).to respond_to(:to_str) }
    it { expect(model.model_name.plural).to respond_to(:to_str) }

    it { expect(instance).to respond_to(:model_name) }
    it { expect(instance.model_name).to eq(model.model_name) }
  end

  context "#test_errors_aref" do
    it "The model should respond to errors" do
      expect(instance).to respond_to(:errors)
    end

    it "errors#[] should return an Array" do
      expect(instance.errors[:hello]).to be_kind_of(Array)
    end
  end
end
