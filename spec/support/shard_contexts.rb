shared_context "FindableModels" do
  before { class Tag < Findable::Base; end }
  after { Object.send(:remove_const, "Tag") }

  let(:findable_model) { Tag }
  let(:findable_instance) { Tag.new }
end

shared_context "AssociationModels" do
  before do
    class Group < Findable::Base; end
    class Tag < Findable::Base; end
    class Info < Findable::Base; end
    Group.has_many :tags
    Group.has_one :info
    Tag.belongs_to :group
    Info.belongs_to :group

    Group.query.import([{id: 1, name: "group1"}])
    Tag.query.import([
      {id: 1, name: "tag1", group_id: 1},
      {id: 2, name: "tag2", group_id: 1},
    ])
    Info.query.import([{id: 1, group_id: 1}])
  end

  after { %w(Group Tag Info).each {|name| Object.send(:remove_const, name) } }
end

