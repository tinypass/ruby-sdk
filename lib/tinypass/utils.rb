module Tinypass
  module Utils
    extend self

    def valid_ip?(ip)
      ip && ip =~ /\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}/
    end

    def parse_loose_period_in_msecs(period)
      period = period.to_s
      return period.to_i if period.to_i.to_s == period

      if matches = /(\d+)\s*(\w+)/.match(period)
        number = matches[1].to_i
        string = matches[2]

        return number if string.start_with?("ms")
        return number * 1000 if string.start_with?("s")
        return number * 1000 * 60 if string.start_with?("mi")
        return number * 1000 * 60 * 60 if string.start_with?("h")
        return number * 1000 * 60 * 60 * 24 if string.start_with?("d")
        return number * 1000 * 60 * 60 * 24 * 7 if string.start_with?("w")
        return number * 1000 * 60 * 60 * 24 * 30 if string.start_with?("mo")
        return number * 1000 * 60 * 60 * 24 * 365 if string.start_with?("y")
      end

      raise ArgumentError.new("Cannot parse the specified period: #{ period }")
    end

    def parse_loose_period_in_secs(period)
      parse_loose_period_in_msecs(period) / 1000
    end
  end
end