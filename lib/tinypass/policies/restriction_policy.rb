module Tinypass
  class RestrictionPolicy < Policy
    def self.limit_purchases_in_period_by_amount(amount, within_period, link_with_details = nil)
      policy = new

      policy[POLICY_TYPE] = RESTRICT_MAX_PURCHASES
      policy['amount'] = amount
      policy['withinPeriod'] = within_period
      policy['linkWithDetails'] = link_with_details if link_with_details

      policy
    end
  end
end