shared_context "TemporaryModel" do
  before { class Size < Findable::Base; define_field :name; end }
  after { Size.delete_all; Object.send(:remove_const, "Size") }
  let(:model) { Size }
  let(:instance) { model.new }
end

# model for read only test
shared_context "ReadOnlyModel" do
  let(:read_model) { Category }
  let(:id) { CategoryData.first[:id] }
  let(:invalid_id) { CategoryData.last[:id] + 1 }
  let(:name) { CategoryData.first[:name] }
  let(:invalid_name) { "invalid" }
end
