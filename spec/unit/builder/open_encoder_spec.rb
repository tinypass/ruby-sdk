require 'spec_helper'

describe Tinypass::OpenEncoder do
  describe '#encode' do
    it "is a passthrough" do
      expect(Tinypass::OpenEncoder.new.encode('the original string')).to eq 'the original string'
    end
  end

  describe '#decode' do
    it "is a passthrough" do
      expect(Tinypass::OpenEncoder.new.decode('the original string')).to eq 'the original string'
    end
  end
end