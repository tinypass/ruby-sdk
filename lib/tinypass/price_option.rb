module Tinypass
  class PriceOption
    attr_accessor :price, :access_period, :caption, :start_date_in_secs, :end_date_in_secs
    attr_reader :split_pays

    def initialize(price, access_period = nil, start_date_in_secs = nil, end_date_in_secs = nil)
      @split_pays = {}

      @price, @access_period = price, access_period

      @start_date_in_secs = TokenData.convert_to_epoch_seconds(start_date_in_secs) if start_date_in_secs
      @end_date_in_secs = TokenData.convert_to_epoch_seconds(end_date_in_secs) if end_date_in_secs
    end

    def access_period_in_msecs
      Utils.parse_loose_period_in_msecs(@access_period)
    end

    def access_period_in_secs
      access_period_in_msecs / 1000
    end

    def active?(timestamp = nil)
      timestamp ||= Time.now.to_i
      timestamp = TokenData.convert_to_epoch_seconds(timestamp)

      return false if start_date_in_secs && timestamp < start_date_in_secs
      return false if end_date_in_secs && timestamp > end_date_in_secs
      return true
    end

    def caption=(value)
      value = value[0...50] if value
      @caption = value
    end

    def add_split_pay(email, amount)
      amount = amount[0..-2].to_f / 100.0 if amount.end_with?('%')
      amount = amount.to_f

      @split_pays[email] = amount
    end

    def to_s
      string = "Price:#{ price }\tPeriod:#{ access_period }\tTrial Period:#{ access_period }"

      if start_date_in_secs
        string << "\tStart:#{ start_date_in_secs }:#{ Time.at(start_date_in_secs).strftime('%a, %d %b %Y %H %M %S') }"
      end

      if end_date_in_secs
        string << "\tEnd:#{ end_date_in_secs }:#{ Time.at(end_date_in_secs).strftime('%a, %d %b %Y %H %M %S') }"
      end

      string << "\tCaption:#{ caption }" if caption

      if @split_pays.any?
        @split_pays.each do |email, amount|
          string << "\tSplit:#{ email }:#{ amount }"
        end
      end

      string
    end
  end
end