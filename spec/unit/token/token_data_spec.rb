require 'spec_helper.rb'

describe Tinypass::TokenData do
  let(:token_data) { Tinypass::TokenData.new }

  it "supports hash writes and reads" do
    token_data[:key] = 'value'
    expect(token_data['key']).to eq 'value'
    expect(token_data[:key]).to eq 'value'
  end

  describe "#rid returns the rid" do
    it "returns the rid field" do
      token_data[Tinypass::TokenData::RID] = 'the rid'
      expect(token_data[Tinypass::TokenData::RID]).to eq 'the rid'
    end
  end

  describe "#values" do
    it "returns the internal hash" do
      token_data[:key] = 'value'
      expect(token_data.values).to eq('key' => 'value')
    end
  end

  describe "#fetch" do
    it "returns the value when present" do
      token_data[:key] = 'value'
      expect(token_data.fetch(:key)).to eq 'value'
    end

    it "returns the default when not" do
      expect(token_data.fetch(:key, 'default value')).to eq 'default value'
    end
  end

  describe "#size" do
    it "returns 0 when new" do
      expect(token_data.size).to eq 0
    end

    it "returns the size when populated" do
      token_data[:key] = 'value'
      token_data['other_key'] = 123
      expect(token_data.size).to eq 2
    end
  end

  describe "#merge" do
    it "sets more than one value at once" do
      token_data.merge(key_1: 1, key_2: 2)
      token_data.merge(key_3: 'abc', key_4: 'def')
      expect(token_data.values).to eq('key_1' => 1, 'key_2' => 2, 'key_3' => 'abc', 'key_4' => 'def')
    end
  end

  describe ".convert_to_epoch_seconds" do
    it "returns the input if before the year ~43k AD" do
      expect(Tinypass::TokenData.convert_to_epoch_seconds(1000)).to eq 1000
    end

    it "converts from milliseconds if beyond the year ~43k AD" do
      expect(Tinypass::TokenData.convert_to_epoch_seconds(1293858000000 + 1)).to eq 1293858000
    end
  end
end