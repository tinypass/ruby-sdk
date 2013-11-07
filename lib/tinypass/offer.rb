module Tinypass
  class Offer
    attr_reader :resource, :pricing, :policies, :tags

    def initialize(resource, *price_options_or_policy)
      raise ArgumentError.new("Can't initialize offer without price options or policy") if price_options_or_policy.empty?

      @resource = resource
      @policies = []
      @tags = []

      if price_options_or_policy.first.kind_of?(PricingPolicy)
        @pricing = price_options_or_policy.first
      else
        @pricing = PricingPolicy.new(price_options_or_policy)
      end
    end

    def has_active_prices?
      pricing.has_active_options?
    end
  end
end