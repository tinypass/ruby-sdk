module Tinypass
  class PricingPolicy < Policy
    attr_reader :price_options

    def initialize(price_options)
      @price_options = Array(price_options)
    end

    def has_active_options?
      price_options.any? { |price_option| price_option.active? }
    end
  end
end