require "spec_helper"

describe Findable::Configuration do
  let(:redis) { {host: "localhost", port: 6379, db: 15} }
  let(:seeds) { "/path/to/seeds.rb" }

  describe "#initialize" do
    subject { Findable.config  }

    # defined options
    Findable::Configuration::VALID_OPTIONS.each do |key|
      it { is_expected.to respond_to(key) }
    end

    # default settings
    it { is_expected.to have_attributes(redis_options: nil) }
    it { is_expected.to have_attributes(seed_file: nil) }
  end

  describe "#merge" do
    subject { Findable.config.merge(seed_file: seeds) }

    it { is_expected.to have_attributes(seed_file: seeds) }
    it { is_expected.to be_kind_of(Findable::Configuration) }
  end

  describe "#merge!" do
    subject { Findable.config.merge!(seed_file: seeds) }

    it { is_expected.to have_attributes(seed_file: seeds) }
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
          config.redis_options = redis
          config.seed_file = seeds
        end
      end

      subject { Findable.config }

      it { is_expected.to have_attributes(seed_file: seeds) }
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

