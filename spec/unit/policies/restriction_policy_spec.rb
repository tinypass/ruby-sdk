require 'spec_helper'

describe Tinypass::RestrictionPolicy do
  describe '#limit_purchases_in_period_by_amount' do
    let(:data) { Tinypass::RestrictionPolicy.limit_purchases_in_period_by_amount('10', '1 week') }
    let(:hash) { data.to_hash }

    it 'returns a RestrictionPolicy' do
      expect(data).to be_kind_of Tinypass::RestrictionPolicy
    end

    it 'sets the type' do
      expect(hash[Tinypass::Policy::POLICY_TYPE]).to eq Tinypass::Policy::RESTRICT_MAX_PURCHASES
    end

    it 'sets the values' do
      expect(hash['amount']).to eq '10'
      expect(hash['withinPeriod']).to eq '1 week'
    end

    context "with details" do
      let(:data) { Tinypass::RestrictionPolicy.limit_purchases_in_period_by_amount('10', '1 week', 'details') }

      it 'sets the type' do
        expect(hash[Tinypass::Policy::POLICY_TYPE]).to eq Tinypass::Policy::RESTRICT_MAX_PURCHASES
      end

      it 'sets the values' do
        expect(hash['amount']).to eq '10'
        expect(hash['withinPeriod']).to eq '1 week'
        expect(hash['linkWithDetails']).to eq 'details'
      end
    end
  end
end