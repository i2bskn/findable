require "spec_helper"

describe Findable::Associations::Utils do
  let(:utils) { Findable::Associations::Utils }

  describe "#model_for" do
    include_context "FindableModels"
    let(:model_name) { findable_model.model_name }

    it { expect(utils.model_for(model_name.singular)).to eq(findable_model) }
    it { expect(utils.model_for(model_name.plural, collection: true)).to eq(findable_model) }
    it { expect(utils.model_for("invalid", class_name: model_name.name)).to eq(findable_model) }

    it { expect { utils.model_for("invalid") }.to raise_error }
    it { expect { utils.model_for("invalid", safe: true) }.not_to raise_error }
    it { expect(utils.model_for("invalid", safe: true)).to be_nil }
  end

  describe "#parse_args" do
    let(:parsed_args) { [:some_name, {class_name: "SomeClass"}] }
    let(:args) { [parsed_args.first, **parsed_args.last] }

    it { expect(utils.parse_args(args)).to eq(parsed_args) }

    it {
      expect {
        utils.parse_args(args)
      }.not_to change { args }
    }
  end
end

