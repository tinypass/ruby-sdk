require 'spec_helper.rb'

describe Tinypass::AccessTokenList do
  let(:list) { Tinypass::AccessTokenList.new }
  let(:token) { Tinypass::AccessToken.new('present') }
  let(:other_token) { Tinypass::AccessToken.new(123456) }
  let(:tokens) { [token, other_token] }

  describe "#initialize" do
    it "accepts an access token" do
      list = Tinypass::AccessTokenList.new(token)
      expect(list[token.rid]).not_to be_nil
    end

    it "accepts an array of access tokens" do
      list = Tinypass::AccessTokenList.new(tokens)
      expect(list[token.rid]).not_to be_nil
      expect(list[other_token.rid]).not_to be_nil
    end
  end

  describe "#tokens, by default" do
    it "is not null" do
      expect(list.tokens).not_to be_nil
    end

    it "is empty" do
      expect(list.tokens.size).to eq 0
    end
  end

  describe "#contains" do
    context "when empty" do
      it "returns false" do
        expect(list.empty?).to be_true
        expect(list.contains?(123)).to be_false
      end
    end

    context "when not empty" do
      let(:list) { Tinypass::AccessTokenList.new(tokens) }

      before do
        Tinypass::AccessToken.new('absent')
        expect(list.empty?).to be_false
      end

      it "returns true for present token RIDs" do
        expect(list.include?(token.rid)).to be_true #test alias
        expect(list.contains?(other_token.rid)).to be_true
      end

      it "returns false for absent token RIDs" do
        expect(list.contains?('absent')).to be_false
      end
    end
  end

  describe "#<<" do
    before do
      stub_const('Tinypass::AccessTokenList::MAX', 1)
    end

    it "adds the token to the list if we haven't reached the max" do
      list << token
      expect(list.length).to eq 1
      expect(list.first).to eq token
    end

    it "drops the oldest tokens if we reach the max" do
      list << token
      list << other_token
      expect(list.length).to eq 1
      expect(list.first).to eq other_token
    end
  end

  describe "#add_all" do
    it "adds all the tokens" do
      list.add_all(tokens)
      expect(list.length).to eq 2
    end
  end

  describe "#empty?" do
    it "returns true when empty" do
      expect(list).to be_empty
    end

    it "returns false when populated" do
      expect(Tinypass::AccessTokenList.new(token)).not_to be_empty
    end
  end
end