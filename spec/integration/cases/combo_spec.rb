require 'spec_helper'

feature 'Combo Both Token Lists' do
  let(:store) { Tinypass::AccessTokenStore.new }

  scenario 'expired tokens are present' do
    token_1 = Tinypass::AccessToken.new('RID1', Time.now.to_i - 1)
    token_2 = Tinypass::AccessToken.new('RID2')
    token_2.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token_2.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
    token_2.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 1
    token_3 = Tinypass::AccessToken.new('RID3', Time.now.to_i - 30)
    cookies = build_tinypass_cookie([token_1, token_2, token_3])
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 3
    expect(store.get_access_token('RID1').access_granted?).to be_false
    expect(store.get_access_token('RID2').access_granted?).to be_false
    expect(store.get_access_token('RID3').access_granted?).to be_false
    expect(store.get_access_token('RID2').trial_dead?).to be_true
  end

  scenario 'expired tokens are absent from meter store' do
    # NOTE: this is ugly, because it was ported from code that used the now-gone MeterStore

    token_1 = Tinypass::AccessToken.new('RID1', Time.now.to_i - 1)
    token_2 = Tinypass::AccessToken.new('RID2')
    token_2.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token_2.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
    token_2.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 1
    token_3 = Tinypass::AccessToken.new('RID3', Time.now.to_i - 30)
    cookies_1 = build_tinypass_cookie([token_1, token_2, token_3], 'RID1')
    cookies_2 = build_tinypass_cookie([token_1, token_2, token_3], 'RID2')
    cookies_3 = build_tinypass_cookie([token_1, token_2, token_3], 'RID3')
    meter_1 = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies_1)
    meter_2 = Tinypass::MeterHelper.load_meter_from_cookie('RID2', cookies_2)
    meter_3 = Tinypass::MeterHelper.load_meter_from_cookie('RID2', cookies_3)

    expect(meter_1).to be_nil
    expect(meter_2).to be_nil
    expect(meter_3).to be_nil
  end
end
