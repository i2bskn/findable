shared_context "FindableModels" do
  let(:findable_model) { Tag }
  let(:findable_instance) { Tag.new }
end

shared_context "TemporaryModel" do
  before { class Size < Findable::Base; define_field :name; end }
  after { Size.delete_all; Object.send(:remove_const, "Size") }
  let(:model) { Size }
end

shared_context "ReadModel" do
  let(:read_model) { Group }
  let(:id) { 1 }
  let(:invalid_id) { 2 }
  let(:name) { "group1" }
  let(:invalid_name) { "invalid" }
end

