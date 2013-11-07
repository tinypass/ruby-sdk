module Tinypass
  class Meter
    def initialize(access_token)
      @access_token = access_token
    end

    def self.create_view_based(rid, max_views, trial_period)
      access_token = AccessToken.new(rid)
      end_time = Utils.parse_loose_period_in_secs(trial_period) + Time.now.to_i

      access_token.token_data[TokenData::METER_TYPE] = TokenData::METER_REMINDER
      access_token.token_data[TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS] = max_views
      access_token.token_data[TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = 0
      access_token.token_data[TokenData::METER_TRIAL_ENDTIME] = end_time
      access_token.token_data[TokenData::METER_LOCKOUT_ENDTIME] = end_time

      new(access_token)
    end

    def self.create_time_based(rid, trial_period, lockout_period)
      access_token = AccessToken.new(rid)
      trial_end_time = Utils::parse_loose_period_in_secs(trial_period) + Time.now.to_i
      lockout_end_time = trial_end_time + Utils::parse_loose_period_in_secs(lockout_period)

      access_token.token_data[TokenData::METER_TYPE] = TokenData::METER_REMINDER
      access_token.token_data[TokenData::METER_TRIAL_ENDTIME] = trial_end_time
      access_token.token_data[TokenData::METER_LOCKOUT_ENDTIME] = lockout_end_time

      new(access_token)
    end

    def increment
      data[TokenData::METER_TRIAL_ACCESS_ATTEMPTS] = trial_view_count + 1
    end

    def trial_period_active?
      @access_token.trial_period_active?
    end

    def lockout_period_active?
      @access_token.lockout_period_active?
    end

    def data
      @access_token.token_data
    end

    def view_based?
      @access_token.meter_view_based?
    end

    def trial_view_count
      @access_token.trial_view_count
    end

    def trial_view_limit
      @access_token.trial_view_limit
    end

    def trial_dead?
      @access_token.trial_dead?
    end

    def meter_type
      @access_token.meter_type
    end

    def trial_end_time_secs
      @access_token.trial_end_time_secs
    end

    def lockout_end_time_secs
      @access_token.lockout_end_time_secs
    end
  end
end