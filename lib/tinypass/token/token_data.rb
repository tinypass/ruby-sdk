module Tinypass
  class TokenData
    MARK_YEAR_MILLIS = 1293858000000

    METER_REMINDER = 10
    METER_STRICT = 20

    METER_TRIAL_ENDTIME = 'mtet'
    METER_TRIAL_ACCESS_PERIOD = 'mtap'

    METER_LOCKOUT_ENDTIME = 'mlet'
    METER_LOCKOUT_PERIOD = 'mlp'

    METER_TRIAL_MAX_ACCESS_ATTEMPTS = 'mtma'
    METER_TRIAL_ACCESS_ATTEMPTS = 'mtaa'
    METER_TYPE = 'mt'

    ACCESS_ID = 'id'

    RID = 'rid'
    UID = 'uid'
    EX = 'ex'
    EARLY_EX = 'eex'
    IPS = 'ips'

    def initialize(data = {})
      @data = data
    end

    def rid
      @data[RID]
    end

    def [](key)
      key = key.to_s
      @data[key]
    end

    def []=(key, value)
      key = key.to_s
      @data[key] = value
    end

    def values
      @data
    end

    def fetch(*args)
      args[0] = args[0].to_s
      @data.fetch(*args)
    end

    def merge(hash)
      stringified_hash = {}
      hash.keys.each do |key|
        stringified_hash[key.to_s] = hash[key]
      end

      @data.merge!(stringified_hash)
    end
    alias_method :add_fields, :merge

    def size
      @data.size
    end

    def self.convert_to_epoch_seconds(seconds_from_now)
      seconds_from_now /= 1000 if seconds_from_now > MARK_YEAR_MILLIS
      seconds_from_now
    end
  end
end