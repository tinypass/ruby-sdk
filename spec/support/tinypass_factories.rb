module TinypassFactories
  def build_tinypass_cookie(tokens, name = nil)
    name ||= Tinypass::Config.token_cookie_name(Tinypass.aid)
    list = Tinypass::AccessTokenList.new(tokens)
    value = Tinypass::ClientBuilder.new.build_access_tokens(list)

    { name => value }
  end

  def build_expired_trial_access_token(rid)
    token = Tinypass::AccessToken.new(rid, 0)
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i - 1

    token
  end

  def build_active_trial_access_token(rid)
    token = Tinypass::AccessToken.new(rid, 0)
    token.token_data[Tinypass::TokenData::METER_TYPE] = Tinypass::TokenData::METER_STRICT
    token.token_data[Tinypass::TokenData::METER_TRIAL_ENDTIME] = Time.now.to_i + 24 * 60 * 60

    token
  end
end