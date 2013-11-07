module Tinypass
  class AccessToken
    attr_accessor :access_state, :token_data

    def initialize(rid_or_token_data, expiration_in_seconds = nil, early_expiration_in_seconds = nil)
      if rid_or_token_data.kind_of?(TokenData)
        self.token_data = rid_or_token_data
        return
      end

      expiration_in_seconds ||= 0
      early_expiration_in_seconds ||= 0

      token_data = TokenData.new
      token_data[TokenData::RID] = rid_or_token_data.to_s
      token_data[TokenData::EX] = TokenData.convert_to_epoch_seconds(expiration_in_seconds)
      token_data[TokenData::EARLY_EX] = TokenData.convert_to_epoch_seconds(early_expiration_in_seconds)
      self.token_data = token_data
    end

    def rid
      token_data.rid
    end

    def access_id
      token_data[TokenData::ACCESS_ID]
    end

    def uid
      token_data.fetch(TokenData::UID, 0)
    end

    def expiration_in_seconds
      token_data.fetch(TokenData::EX, 0)
    end
    alias_method :expiration_in_secs, :expiration_in_seconds

    def early_expiration_in_seconds
      token_data.fetch(TokenData::EARLY_EX, 0)
    end
    alias_method :early_expiration_in_secs, :early_expiration_in_seconds

    def trial_end_time_secs
      token_data.fetch(TokenData::METER_TRIAL_ENDTIME, 0)
    end

    def lockout_end_time_secs
      token_data.fetch(TokenData::METER_LOCKOUT_ENDTIME, 0)
    end

    def trial_view_count
      token_data.fetch(TokenData::METER_TRIAL_ACCESS_ATTEMPTS, 0)
    end

    def trial_view_limit
      token_data.fetch(TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS, 0)
    end

    def metered?
      meter_type != 0
    end

    def meter_view_based?
      metered? && token_data[TokenData::METER_TRIAL_MAX_ACCESS_ATTEMPTS]
    end

    def meter_type
      token_data.fetch(TokenData::METER_TYPE, 0)
    end

    def ips
      token_data.fetch(TokenData::IPS, [])
    end

    def access_state
      access_granted? if @access_state.nil?
      @access_state
    end

    def access_granted?(client_ip = nil)
      if expiration_in_seconds == -1
        # special case. RID_NOT_FOUND
        @access_state = AccessState::RID_NOT_FOUND if @access_state != AccessState::NO_TOKENS_FOUND
        return false
      end

      if Utils::valid_ip?(client_ip) && ips.any? && !ips.include?(client_ip)
        @access_state = AccessState::CLIENT_IP_DOES_NOT_MATCH_TOKEN
        return false
      end

      if metered?
        if trial_period_active?
          @access_state = AccessState::METERED_IN_TRIAL
          return true
        end

        if lockout_period_active?
          @access_state = AccessState::METERED_IN_LOCKOUT
        else
          @access_state = AccessState::METERED_TRIAL_DEAD
        end

        return false
      end

      if expired?
        @access_state = AccessState::EXPIRED
        return false
      end

      @access_state = AccessState::ACCESS_GRANTED
      true
    end

    def trial_period_active?
      return false unless metered?

      if meter_type == TokenData::METER_STRICT
        return Time.now.to_i <= trial_end_time_secs
      end

      if meter_view_based?
        return trial_view_count <= trial_view_limit && Time.now.to_i <= trial_end_time_secs
      end

      # unknown meter
      return trial_end_time_secs == 0 || Time.now.to_i <= trial_end_time_secs
    end

    def lockout_period_active?
      return false unless metered?
      return false if trial_period_active?

      return Time.now.to_i <= lockout_end_time_secs
    end

    def expired?
      expiration = early_expiration_in_seconds
      expiration = expiration_in_seconds if expiration == 0

      return false if expiration == 0

      expiration <= Time.now.to_i
    end

    def trial_dead?
      !lockout_period_active? && !trial_period_active?
    end
  end

  module AccessState
    ACCESS_GRANTED = 100;
    CLIENT_IP_DOES_NOT_MATCH_TOKEN = 200
    RID_NOT_FOUND = 201
    NO_TOKENS_FOUND = 202
    METERED_IN_TRIAL = 203
    EXPIRED = 204
    NO_ACTIVE_PRICES = 205
    METERED_IN_LOCKOUT = 206
    METERED_TRIAL_DEAD = 207
  end
end