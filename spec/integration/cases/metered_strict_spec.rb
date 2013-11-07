require 'spec_helper'

feature 'Metered Access (strict)' do
  let(:store) { Tinypass::AccessTokenStore.new }

  scenario 'trial period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 9
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 9
    cookies = build_tinypass_cookie(token)
    store.load_tokens_from_cookie(cookies)
    retrieved_token = store.get_access_token('RID1')

    expect(store.tokens.size).to eq 1
    expect(retrieved_token.access_granted?).to be_true
    expect(retrieved_token.trial_period_active?).to be_true
    expect(retrieved_token.lockout_period_active?).to be_false
    expect(retrieved_token.trial_dead?).to be_false
    expect(retrieved_token.token_data[Tinypass::TokenData::METER_TYPE]).to eq Tinypass::TokenData::METER_STRICT
  end

  scenario 'lockout period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 3
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 3
    cookies = build_tinypass_cookie(token)
    store.load_tokens_from_cookie(cookies)
    retrieved_token = store.get_access_token('RID1')

    expect(store.tokens.size).to eq 1
    expect(retrieved_token.access_granted?).to be_false
    expect(retrieved_token.trial_period_active?).to be_false
    expect(retrieved_token.lockout_period_active?).to be_true
    expect(retrieved_token.trial_dead?).to be_false
    expect(retrieved_token.token_data[Tinypass::TokenData::METER_TYPE]).to eq Tinypass::TokenData::METER_STRICT
  end

  scenario 'expired tokens are present in store' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 3
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 3
    token_2 = Tinypass::AccessToken.new('RID2')
    token_2.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token_2.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 3
    token_2.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 3
    cookies = build_tinypass_cookie([token, token_2])
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 2
  end
end