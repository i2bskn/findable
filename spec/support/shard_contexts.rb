shared_context "FindableModels" do
  let(:findable_model) { Tag }
  let(:findable_instance) { Tag.new }
end

shared_context "TemporaryModel" do
  before { class Size < Findable::Base; define_field :name; end }
  after { Size.delete_all; Object.send(:remove_const, "Size") }
  let(:model) { Size }
end

