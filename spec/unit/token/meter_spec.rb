require 'spec_helper'

describe Tinypass::Meter do
  describe "#increment" do
    it "increments the view count" do
      meter = Tinypass::Meter.create_view_based('rid', 100, '1 day')
      meter.increment
      expect(meter.trial_view_count).to eq 1
    end
  end

  describe "#data" do
    it "returns the TokenData" do
      meter = Tinypass::Meter.create_time_based('rid', '1 week', '24 hours')
      data = meter.data

      expect(data.rid).to eq 'rid'
      expect(data[Tinypass::TokenData::METER_TRIAL_ENDTIME]).to eq Time.now.to_i + 60 * 60 * 24 * 7
      expect(data[Tinypass::TokenData::METER_LOCKOUT_ENDTIME]).to eq Time.now.to_i + 60 * 60 * 24 * 8
    end
  end

  describe ".create_view_based" do
    let(:max_views) { 123 }
    let(:trial_period) { '1 day' }
    let(:meter) { Tinypass::Meter.create_view_based('rid', max_views, trial_period) }

    it "returns a meter" do
      expect(meter).to be_kind_of Tinypass::Meter
    end

    it "sets the fields" do
      expect(meter.view_based?).to be_true
      expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
      expect(meter.trial_view_count).to eq 0
      expect(meter.trial_view_limit).to eq max_views
      expect(meter.trial_end_time_secs).to eq Time.now.to_i + 60 * 60 * 24
      expect(meter.lockout_end_time_secs).to eq Time.now.to_i + 60 * 60 * 24

      expect(meter.trial_dead?).to be_false
      expect(meter.trial_period_active?).to be_true
      expect(meter.lockout_period_active?).to be_false
    end
  end

  describe ".create_time_based" do
    let(:trial_period) { '1 day' }
    let(:lockout_period) { '1 day' }
    let(:meter) { Tinypass::Meter.create_time_based('rid', trial_period, lockout_period) }

    it "returns a meter" do
      expect(meter).to be_kind_of Tinypass::Meter
    end

    it "sets the fields" do
      expect(meter.view_based?).to be_false
      expect(meter.meter_type).to eq Tinypass::TokenData::METER_REMINDER
      expect(meter.trial_end_time_secs).to eq Time.now.to_i + 60 * 60 * 24
      expect(meter.lockout_end_time_secs).to eq Time.now.to_i + 60 * 60 * 24 * 2

      expect(meter.trial_dead?).to be_false
      expect(meter.trial_period_active?).to be_true
      expect(meter.lockout_period_active?).to be_false
    end
  end
end