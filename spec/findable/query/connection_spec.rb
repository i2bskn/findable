require "spec_helper"

describe Findable::Query::Connection do
  before do
    class QueryEx; end
    QueryEx.include Findable::Query::Connection
  end

  after do
    Object.send(:remove_const, "QueryEx")
  end

  let(:query) { QueryEx.new }
  let(:custom_options) { {host: "localhost", port: 6379, db: 15} }

  describe "#redis" do
    it { expect(query.redis).to be_kind_of(Redis) }
    it {
      expect(query).to receive(:generate_redis_connection!)
      query.redis
    }
  end

  describe "#generate_redis_connection!" do
    context "when redis_options is nil" do
      before { Findable.config.redis_options = nil }

      it { expect(query.send(:generate_redis_connection!)).to be_kind_of(Redis) }
      it {
        expect(Redis).not_to receive(:new)
        expect(Redis).to receive(:current)
        query.redis
      }
    end

    context "when redis_options is not nil" do
      before { Findable.config.redis_options = custom_options }

      it { expect(query.send(:generate_redis_connection!)).to be_kind_of(Redis) }
      it {
        expect(Redis).to receive(:new)
        expect(Redis).not_to receive(:current)
        query.redis
      }
    end
  end

  describe "#redis_options" do
    context "with custom options" do
      it {
        Findable.config.redis_options = custom_options
        expect(query.send(:redis_options)).to eq(custom_options)
      }
    end

    context "without custom options" do
      after { expect(query.send(:redis_options)).to be_nil }

      it { Findable.config.redis_options = nil }
      it { Findable.config.redis_options = {} }
    end
  end
end

