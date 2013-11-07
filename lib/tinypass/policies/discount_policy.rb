module Tinypass
  class DiscountPolicy < Policy
    def self.on_total_spend_in_period(amount, within_period, discount)
      policy = new

      policy[POLICY_TYPE] = DISCOUNT_TOTAL_IN_PERIOD
      policy["amount"] = amount
      policy["withinPeriod"] = within_period
      policy["discount"] = discount

      policy
    end

    def self.previous_purchased(rids, discount)
      rids = Array(rids)
      policy = new

      policy[POLICY_TYPE] = DISCOUNT_PREVIOUS_PURCHASE
      policy["rids"] = rids
      policy["discount"] = discount

      policy
    end
  end
end