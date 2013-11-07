require 'spec_helper'

describe Tinypass::DiscountPolicy do
  describe '#on_total_spend_in_period' do
    let(:data) { Tinypass::DiscountPolicy.on_total_spend_in_period('100', '1 week', '50%') }
    let(:hash) { data.to_hash }

    it 'returns a DiscountPolicy' do
      expect(data).to be_kind_of Tinypass::DiscountPolicy
    end

    it 'sets the type' do
      expect(hash[Tinypass::Policy::POLICY_TYPE]).to eq Tinypass::Policy::DISCOUNT_TOTAL_IN_PERIOD
    end

    it 'sets the values' do
      expect(hash['amount']).to eq '100'
      expect(hash['withinPeriod']).to eq '1 week'
      expect(hash['discount']).to eq '50%'
    end
  end

  describe '#previous_purchased' do
    let(:data) { Tinypass::DiscountPolicy.previous_purchased(['RID1'], '50%') }
    let(:hash) { data.to_hash }

    it 'returns a DiscountPolicy' do
      expect(data).to be_kind_of Tinypass::DiscountPolicy
    end

    it 'sets the type' do
      expect(hash[Tinypass::Policy::POLICY_TYPE]).to eq Tinypass::Policy::DISCOUNT_PREVIOUS_PURCHASE
    end

    it 'sets the values' do
      expect(hash['rids']).to eq ['RID1']
      expect(hash['discount']).to eq '50%'
    end
  end
end