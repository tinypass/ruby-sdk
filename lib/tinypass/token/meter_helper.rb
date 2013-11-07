module Tinypass
  module MeterHelper
    extend self

    def create_view_based(name, max_views, within_period)
      Meter.create_view_based(name, max_views, within_period)
    end

    def create_time_based(name, trial_period, lockout_period)
      Meter.create_time_based(name, trial_period, lockout_period)
    end

    def load_meter_from_cookie(meter_name, cookies)
      # NOTE: This method expects `meter_name` to be both the cookie name and the meter name
      #   aka rid.

      store = AccessTokenStore.new
      store.load_tokens_from_cookie(cookies, meter_name)

      return unless store.has_token?(meter_name)

      token = store.get_access_token(meter_name)
      meter = Meter.new(token)

      return if meter.trial_dead?
      meter
    end

    def load_meter_from_serialized_data(string)
      store = AccessTokenStore.new
      store.load_tokens_from_cookie(string)
      token = store.tokens.first

      return if token.nil?

      meter = Meter.new(token)

      return if meter.trial_dead?
      meter
    end

    def serialize(meter, builder_config = '')
      token = AccessToken.new(meter.data)
      builder = ClientBuilder.new(builder_config)
      builder.build_access_tokens(token)
    end

    def serialize_to_json(meter)
      serialize(meter, ClientBuilder::OPEN_ENC)
    end

    def deserialize(string)
      parser = ClientParser.new
      list = parser.parse_access_tokens(string)
      token = list.first

      return if token.nil?

      Meter.new(token)
    end

    def generate_cookie_embed_script(name, meter)
      if meter.lockout_period_active?
        expires = meter.lockout_end_time_secs + 60
      else
        expires = Time.now.to_i + 60 * 60 * 24 * 90
      end
      expires_string = Time.at(expires).utc

      "<script>
        document.cookie='#{ generate_local_cookie(name, meter) }; path=/; expires=#{ expires_string };';
      </script>"
    end

    private

    def generate_local_cookie(name, meter)
      cookie_value = URI::escape(serialize(meter))
      "#{ name }=#{ cookie_value }"
    end
  end
end