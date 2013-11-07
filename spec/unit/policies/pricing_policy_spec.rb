require 'spec_helper'

describe Tinypass::PricingPolicy do
  describe 'has_active_options?' do
    it "returns true when it should" do
      policy = Tinypass::PricingPolicy.new([double(active?: true)])

      expect(policy.has_active_options?).to be_true
    end

    it "returns false when it should" do
      policy = Tinypass::PricingPolicy.new(double(active?: false))

      expect(policy.has_active_options?).to be_false
    end

    it "returns false when no options" do
      policy = Tinypass::PricingPolicy.new([])

      expect(policy.has_active_options?).to be_false
    end
  end
end