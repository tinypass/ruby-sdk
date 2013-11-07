module Tinypass
  class Policy
    DISCOUNT_TOTAL_IN_PERIOD = "d1"
    DISCOUNT_PREVIOUS_PURCHASE = "d2"
    STRICT_METER_BY_TIME = "sm1"
    REMINDER_METER_BY_TIME = "rm1"
    REMINDER_METER_BY_COUNT = "rm2"
    RESTRICT_MAX_PURCHASES = "r1"

    POLICY_TYPE = "type"

    def initialize
      @map = {}
    end

    def []=(key,value)
      key = key.to_s
      @map[key] = value
    end

    def to_hash
      @map
    end
  end
end