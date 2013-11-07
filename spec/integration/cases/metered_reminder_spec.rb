require 'spec_helper'

feature 'Metered (reminder)' do
  scenario 'trial period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 3
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 3
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(meter.trial_period_active?).to be_true
    expect(meter.lockout_period_active?).to be_false
    expect(meter.trial_dead?).to be_false
    expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
  end

  scenario 'lock period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 3
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 3
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(meter.trial_period_active?).to be_false
    expect(meter.lockout_period_active?).to be_true
    expect(meter.trial_dead?).to be_false
    expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
  end

  scenario 'meter is nil because expired' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 3
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 3
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(meter).to be_nil
  end
end