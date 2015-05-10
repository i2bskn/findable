require "spec_helper"

describe "Errors" do
  include_context "ReadOnlyModel"

  describe Findable::FindableError do
    it { is_expected.to be_kind_of(StandardError) }
  end

  describe Findable::RecordNotFound do
    let(:error) { Findable::RecordNotFound.new(read_model, {id: 1}) }
    it { expect(error).to be_kind_of(Findable::FindableError) }
    it { expect(error.message).to match(Regexp.new(read_model.model_name.name)) }
    it { expect(error.message).to match(Regexp.new({id: 1}.inspect)) }
  end
end

