require 'spec_helper.rb'

describe Tinypass::AccessToken do
  let(:token) { Tinypass::AccessToken.new('123456', 3000) }

  it "creates token data" do
    expect(token.token_data.values).not_to be_nil
  end

  it "sets the rid" do
    expect(token.rid).to eq '123456'
  end

  describe "#access_id" do
    it "can be retrieved" do
      token.token_data[Tinypass::TokenData::ACCESS_ID] = 'value'
      expect(token.access_id).to eq 'value'
    end
  end

  describe "#uid" do
    it "can be retrieved" do
      token.token_data[Tinypass::TokenData::UID] = 'value'
      expect(token.uid).to eq 'value'
    end
  end

  describe "#expiration_in_seconds" do
    it "can be retrieved" do
      expect(token.expiration_in_seconds).to eq 3000
    end

    it "is aliased as #expiration_in_secs" do
      expect(token.expiration_in_secs).to eq 3000
    end
  end

  describe "#early_expiration_in_seconds" do
    it "defaults to zero" do
      expect(token.early_expiration_in_seconds).to eq 0
    end

    it "is aliased as #expiration_in_secs" do
      expect(token.early_expiration_in_secs).to eq 0
    end
  end

  it "supports trial_end_time_secs" do
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = 4000
    expect(token.trial_end_time_secs).to eq 4000
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = 1000
    expect(token.trial_end_time_secs).to eq 1000
  end

  it "supports lockout_end_time_secs" do
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = 4000
    expect(token.lockout_end_time_secs).to eq 4000
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = 1000
    expect(token.lockout_end_time_secs).to eq 1000
  end

  it "supports trial_view_count" do
    expect(token.trial_view_count).to eq 0
    token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 1000
    expect(token.trial_view_count).to eq 1000
  end

  it "supports trial_view_limit" do
    expect(token.trial_view_limit).to eq 0
    token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 1000
    expect(token.trial_view_limit).to eq 1000
  end

  describe "#access_state" do
    it "returns ACCESS_GRANTED by default" do
      token = Tinypass::AccessToken.new('RID', 0)
      expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
    end
  end

  describe "#access_granted?" do
    it "returns true when not expired" do
      token = Tinypass::AccessToken.new('RID', Time.now.to_i + 4)
      expect(token.access_granted?).to be_true
      expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
    end

    it "returns true when expiration is zero" do
      token = Tinypass::AccessToken.new('RID', 0)
      expect(token.access_granted?).to be_true
      expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
    end

    it "returns true when expiration is nil" do
      token = Tinypass::AccessToken.new('RID', nil)
      expect(token.access_granted?).to be_true
      expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
    end

    it "returns false when expired" do
      token = Tinypass::AccessToken.new('RID', Time.now.to_i - 1)
      expect(token.access_granted?).to be_false
      expect(token.expired?).to be_true
      expect(token.access_state).to eq Tinypass::AccessState::EXPIRED
    end

    it "returns false when early expired" do
      token = Tinypass::AccessToken.new('RID', 0, Time.now.to_i - 1)
      expect(token.access_granted?).to be_false
      expect(token.access_state).to eq Tinypass::AccessState::EXPIRED
    end

    context "when passed an ip" do
      let(:token) { Tinypass::AccessToken.new('RID', 0) }
      it "ignores the ip if no ips set" do
        expect(token.access_granted?('1.1.1.1')).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
      end

      it "ignores the ip if ip included" do
        token.token_data[Tinypass::TokenData::IPS] = ['1.1.1.1']
        expect(token.access_granted?('1.1.1.1')).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::ACCESS_GRANTED
      end

      it "returns false when ip not included" do
        token.token_data[Tinypass::TokenData::IPS] = ['1.1.1.1']
        expect(token.access_granted?('1.1.1.2')).to be_false
        expect(token.access_state).to eq Tinypass::AccessState::CLIENT_IP_DOES_NOT_MATCH_TOKEN
      end
    end

    context "timed meter" do
      let(:token) { Tinypass::AccessToken.new('RID', 0) }

      before do
        token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
      end

      it "returns true when not expired" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 1000
        expect(token.access_granted?).to be_true
        expect(token.metered?).to be_true
        expect(token.trial_period_active?).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::METERED_IN_TRIAL
      end

      it "returns false when expired" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
        expect(token.access_granted?).to be_false
        expect(token.metered?).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::METERED_TRIAL_DEAD
      end

      it "returns false when null" do
        expect(token.access_granted?).to be_false
        expect(token.access_state).to eq Tinypass::AccessState::METERED_TRIAL_DEAD
      end

      it "returns false with special state if locked out" do
        token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 1000
        expect(token.access_granted?).to be_false
        expect(token.access_state).to eq Tinypass::AccessState::METERED_IN_LOCKOUT
      end
    end

    context "view meter" do
      let(:token) { Tinypass::AccessToken.new('RID', 0) }

      before do
        token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
      end

      context "not expired" do
        before do
          token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 1000
        end

        it "returns true when views not exceeded" do
          token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 1
          token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 0
          expect(token.access_granted?).to be_true
          expect(token.access_state).to eq Tinypass::AccessState::METERED_IN_TRIAL
        end

        it "returns false when views exceeded" do
          token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 1
          token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 2 # NOTE: probable off-by-one error
          expect(token.access_granted?).to be_false
          expect(token.access_state).to eq Tinypass::AccessState::METERED_TRIAL_DEAD
        end
      end

      context "expired" do
        before do
          token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
        end

        it "returns false despite views not exceeded" do
          token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 1
          token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 0
          expect(token.access_granted?).to be_false
          expect(token.access_state).to eq Tinypass::AccessState::METERED_TRIAL_DEAD
        end
      end
    end

    context "unknown meter" do
      let(:token) { Tinypass::AccessToken.new('RID', 0) }

      before do
        token.token_data[Tinypass::TokenData::METER_TYPE] = 'unknown meter type'
      end

      it "returns true when not expired" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 1000
        expect(token.access_granted?).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::METERED_IN_TRIAL
      end

      it "returns false when expired" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
        expect(token.access_granted?).to be_false
        expect(token.access_state).to eq Tinypass::AccessState::METERED_TRIAL_DEAD
      end

      it "returns true when null" do
        expect(token.access_granted?).to be_true
        expect(token.access_state).to eq Tinypass::AccessState::METERED_IN_TRIAL
      end
    end
  end

  describe "#trial_dead?" do
    let(:token) { Tinypass::AccessToken.new('RID', 0) }

    it "returns true when not metered" do
      expect(token.trial_dead?).to be_true
    end

    context "when metered" do
      before do
        token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
      end

      it "returns false when trial is active" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 1000
        expect(token.trial_dead?).to be_false
      end

      it "returns false when lockout is active" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
        token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 1000
        expect(token.trial_dead?).to be_false
        expect(token.lockout_period_active?).to be_true
      end

      it "returns true when lockout and trial expired" do
        token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
        token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 1
        expect(token.trial_dead?).to be_true
        expect(token.lockout_period_active?).to be_false
      end
    end
  end

end