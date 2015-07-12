require "spec_helper"

describe Findable::Schema::Conversion do
  after(:each) { conversion.clear_types }
  let(:conversion) { Findable::Schema::Conversion }

  describe ".for" do
    it { expect(conversion.for(nil)).to eq(conversion.types[:default]) }
    it { expect(conversion.for(:integer)).to eq(conversion.types[:integer]) }
    it { expect(conversion.for(:float)).to eq(conversion.types[:float]) }
    it { expect(conversion.for(:decimal)).to eq(conversion.types[:decimal]) }
    it { expect(conversion.for(:string)).to eq(conversion.types[:string]) }
    it { expect(conversion.for(:boolean)).to eq(conversion.types[:boolean]) }
    it { expect(conversion.for(:date)).to eq(conversion.types[:date]) }
    it { expect(conversion.for(:datetime)).to eq(conversion.types[:datetime]) }
    it { expect(conversion.for(:symbol)).to eq(conversion.types[:symbol]) }
    it { expect(conversion.for(:inquiry)).to eq(conversion.types[:inquiry]) }
  end

  describe ".types" do
    it { expect(conversion.types).to be_kind_of(Hash) }
    it { expect(conversion.types[:default]).not_to be_nil }
  end

  describe ".add_type!" do
    it {
      expect {
        conversion.add_type!(:integer)
      }.to change { conversion.types.size }.by(1)
    }
  end

  describe ".integer" do
    it { expect(conversion.send(:integer, "1")).to be_kind_of(Integer) }
    it { expect(conversion.send(:integer, 1)).to eq(1) }
  end

  describe ".float" do
    it { expect(conversion.send(:float, "1")).to be_kind_of(Float) }
    it { expect(conversion.send(:float, 1)).to eq(1.to_f) }
  end

  describe ".decimal" do
    it { expect(conversion.send(:decimal, "1")).to be_kind_of(BigDecimal) }
    it { expect(conversion.send(:decimal, 1)).to eq(BigDecimal(1)) }
  end

  describe ".string" do
    it { expect(conversion.send(:string, 1)).to be_kind_of(String) }
    it { expect(conversion.send(:string, 1)).to eq("1") }
  end

  describe ".boolean" do
    it { expect(conversion.send(:boolean, true)).to be_truthy }
    it { expect(conversion.send(:boolean, false)).to be_falsey }
    it { expect(conversion.send(:boolean, "false")).to be_falsey }
    it { expect(conversion.send(:boolean, "0")).to be_falsey }
    it { expect(conversion.send(:boolean, "true")).to be_truthy }
  end

  describe ".date" do
    let(:strdate) { "2015-07-12" }
    it { expect(conversion.send(:date, strdate)).to be_kind_of(Date) }
    it { expect(conversion.send(:date, strdate)).to eq(Date.parse(strdate)) }
    it {
      d = Date.current
      expect(conversion.send(:date, d)).to eq(d)
    }
  end

  describe ".datetime" do
    let(:strtime) { "2015-07-12 22:15:48 +0900" }
    it { expect(conversion.send(:datetime, strtime)).to be_kind_of(Time) }
    it { expect(conversion.send(:datetime, strtime)).to eq(Time.parse(strtime)) }
    it {
      t = Time.now
      expect(conversion.send(:datetime, t)).to eq(t)
    }
    it {
      t = Time.current
      expect(conversion.send(:datetime, t)).to eq(t)
    }
  end

  describe ".symbol" do
    let(:string) { "string" }
    it { expect(conversion.send(:symbol, string)).to be_kind_of(Symbol) }
    it { expect(conversion.send(:symbol, string)).to eq(string.to_sym) }
  end

  describe ".inquiry" do
    let(:string) { "string" }
    it { expect(conversion.send(:inquiry, string)).to be_kind_of(ActiveSupport::StringInquirer) }
    it { expect(conversion.send(:inquiry, string)).to eq(string.inquiry) }
  end
end
