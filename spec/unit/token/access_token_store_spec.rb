require 'spec_helper.rb'

describe Tinypass::AccessTokenStore do
  let(:store) { Tinypass::AccessTokenStore.new }
  let(:token) { Tinypass::AccessToken.new('RID1', 0) }

  describe "#load_tokens_from_cookie" do
    let(:cookies) { build_tinypass_cookie(token) }

    before do
      store.load_tokens_from_cookie(cookies)
    end

    it "produces tokens with the correct length" do
      expect(store.tokens.length).to eq 1
    end

    it "sets the raw cookie" do
      expect(store.raw_cookie).to eq cookies.values.first
    end

    it "sets the RID correctly" do
      expect(store.get_access_token('RID1')).not_to be_nil # also tests #get_access_token
    end

    it "sets the other values correctly" do
      expect(store.get_access_token('RID1').token_data.values).to eq token.token_data.values # also tests #get_access_token
    end
  end

  describe "#get_access_token" do
    it "returns an RID_NOT_FOUND token if absent and there are tokens" do
      Tinypass::AccessToken.new('not in store', 0)
      store.tokens << token
      found_token = store.get_access_token('not in store')

      expect(found_token).not_to be_nil
      expect(found_token.access_granted?).to be_false
      expect(found_token.metered?).to be_false
      expect(found_token.meter_type).to eq 0
      expect(found_token.trial_period_active?).to be_false
      expect(found_token.lockout_period_active?).to be_false
      expect(found_token.access_state).to eq Tinypass::AccessState::RID_NOT_FOUND
    end

    it "returns an RID_NOT_FOUND token if absent and empty" do
      Tinypass::AccessToken.new('not in store', 0)
      found_token = store.get_access_token('not_in_store')

      expect(found_token).not_to be_nil
      expect(found_token.access_granted?).to eq false
      expect(found_token.access_state).to eq Tinypass::AccessState::NO_TOKENS_FOUND
    end
  end

  describe "#has_token?" do
    it "returns false when empty" do
      expect(store.has_token?('absent')).to be_false
    end

    it "returns true when present" do
      store.tokens << token
      expect(store.has_token?(token.rid)).to be_true
    end

    it "returns false when absent but not empty" do
      expect(store.has_token?('absent')).to be_false
    end
  end

  describe "#find_active_token" do
    it "returns nil when empty" do
      expect(store.find_active_token(/absent/)).to be_nil
    end

    it "returns nil when token is inactive" do
      expired_token = Tinypass::AccessToken.new('expired', Time.now.to_i - 1)
      store.tokens << expired_token

      expect(store.find_active_token(/expired/)).to be_nil
    end

    it "returns the token when found" do
      store.tokens << token
      expect(store.find_active_token(Regexp.new(token.rid))).to eq token
    end

    it "returns the token when not found" do
      store.tokens << token
      expect(store.find_active_token(/absent/)).to be_nil
    end
  end
end