require 'spec_helper'

describe Tinypass::Utils do
  describe "#parse_loose_period_in_msecs" do
    it "throws an exception with unknown strings" do
      expect{ Tinypass::Utils.parse_loose_period_in_msecs("???") }.to raise_error ArgumentError
    end

    it "interprets numbers" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("10000")).to eq 10000
    end

    it "interprets negative numbers" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("-10000")).to eq(-10000)
    end

    it "interprets milliseconds" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 ms")).to eq 123
    end

    it "interprets seconds" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 s")).to eq 123 * 1000
    end

    it "interprets minutes" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 mi")).to eq 123 * 1000 * 60
    end

    it "interprets hours" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 h")).to eq 123 * 1000 * 60 * 60
    end

    it "interprets days" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 d")).to eq 123 * 1000 * 60 * 60 * 24
    end

    it "interprets weeks" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 w")).to eq 123 * 1000 * 60 * 60 * 24 * 7
    end

    it "interprets months" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 mo")).to eq 123 * 1000 * 60 * 60 * 24 * 30
    end

    it "interprets years" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("123 y")).to eq 123 * 1000 * 60 * 60 * 24 * 365
    end

    it "skips digits" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs("112211")).to eq 112211
    end

    it "skips integers" do
      expect(Tinypass::Utils.parse_loose_period_in_msecs(112211)).to eq 112211
    end
  end
end