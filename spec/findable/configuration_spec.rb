require "spec_helper"

describe Findable::Configuration do
  let(:storage) { :memory }
  let(:redis) { {host: "localhost", port: 6379, db: 15} }

  describe "#initialize" do
    subject { Findable.config  }

    # defined options
    Findable::Configuration::VALID_OPTIONS.each do |key|
      it { is_expected.to respond_to(key) }
    end

    # default settings
    it { is_expected.to have_attributes(default_storage: :redis) }
    it { is_expected.to have_attributes(redis_options: nil) }
  end

  describe "#merge" do
    subject { Findable.config.merge(default_storage: storage) }

    it { is_expected.to have_attributes(default_storage: storage) }
    it { is_expected.to be_kind_of(Findable::Configuration) }
  end

  describe "#merge!" do
    subject { Findable.config.merge!(default_storage: storage) }

    it { is_expected.to have_attributes(default_storage: storage) }
    it { is_expected.to be_kind_of(Findable::Configuration) }
  end

  describe "Accessible" do
    context "extended" do
      subject { Module.new { extend Findable::Configuration::Accessible } }

      it { is_expected.to respond_to(:configure) }
      it { is_expected.to respond_to(:config) }
    end

    describe "#configure" do
      before do
        Findable.configure do |config|
          config.default_storage = storage
          config.redis_options = redis
        end
      end

      subject { Findable.config }

      it { is_expected.to have_attributes(default_storage: storage) }
      it { is_expected.to have_attributes(redis_options: redis) }

      it {
        expect {
          Findable.configure {|config| config.unknown = :value }
        }.to raise_error
      }
    end

    describe "#config" do
      it { expect(Findable.config.is_a?(Findable::Configuration)).to be_truthy }
    end
  end
end

