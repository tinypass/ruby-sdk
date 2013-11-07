require 'spec_helper'

feature 'Metered (views)' do
  scenario 'trial period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 10
    token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 9
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 20
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 20
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(token.access_granted?).to be_true
    expect(meter).not_to be_nil
    expect(meter.trial_period_active?).to be_true
    expect(meter.lockout_period_active?).to be_false
    expect(meter.trial_dead?).to be_false
    expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
  end

  scenario 'lock period is active' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 10
    token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 10
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 20
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i + 20
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(token.access_granted?).to be_true
    expect(meter).not_to be_nil

    meter.increment

    expect(meter.trial_period_active?).to be_false
    expect(meter.lockout_period_active?).to be_true
    expect(meter.trial_dead?).to be_false
    expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
  end

  scenario 'meter is nil because expired' do
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 10
    token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 11
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = Time.now.to_i - 1
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(meter).to be_nil
  end

  scenario 'expire time is set when count is exceeded' do
    trial_end = Time.now.to_i + 20
    token = Tinypass::AccessToken.new('RID1')
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_REMINDER
    token.token_data[Tinypass::TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = 4
    token.token_data[Tinypass::TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 0
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = trial_end
    token.token_data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME] = trial_end
    cookies = build_tinypass_cookie(token, 'RID1')
    meter = Tinypass::MeterHelper.load_meter_from_cookie('RID1', cookies)

    expect(meter.trial_view_count).to eq 0

    expect(meter.increment).to eq 1
    expect(meter.trial_view_count).to eq 1
    expect(meter.lockout_end_time_secs).to eq trial_end

    expect(meter.increment).to eq 2
    expect(meter.trial_view_count).to eq 2
    expect(meter.lockout_end_time_secs).to eq trial_end

    expect(meter.increment).to eq 3
    expect(meter.trial_view_count).to eq 3
    expect(meter.lockout_end_time_secs).to eq trial_end

    expect(meter.increment).to eq 4
    expect(meter.trial_view_count).to eq 4
    expect(meter.lockout_end_time_secs).to eq trial_end

    # should kick off the lockout period
    expect(meter.increment).to eq 5
    expect(meter.trial_view_count).to eq 5
    expect(meter.trial_period_active?).to be_false
    expect(meter.lockout_period_active?).to be_true
    expect(meter.lockout_end_time_secs).to eq trial_end
  end
end