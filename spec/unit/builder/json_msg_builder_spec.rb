require 'spec_helper'

describe Tinypass::JsonMsgBuilder do
  describe "#build_purchase_requests" do
    let(:resource) { Tinypass::Resource.new('Premium-Content', 'Site wide premium content access', 'http://resource.com') }
    let(:price_option_1) do
      Tinypass::PriceOption.new('.50', '24 hours').tap do |option|
        option.caption = 'Special offer!'
        option.start_date_in_secs = 123456789
        option.end_date_in_secs = 987654321
        option.add_split_pay('taavo@dd9.com', '50%')
        option.add_split_pay('bob@example.org', '.10')
      end
    end
    let(:price_option_2) { Tinypass::PriceOption.new('.99', '1 week') }
    let(:offer) do
      Tinypass::Offer.new(resource, price_option_1, price_option_2).tap do |offer|
        offer.tags.push('tag', 'another tag', 'a third tag')
      end
    end
    let(:other_offer) { Tinypass::Offer.new(resource, price_option_2, price_option_1) }
    let(:purchase_request) do
      Tinypass::PurchaseRequest.new(offer).tap do |request|
        request.client_ip = '1.2.3.4'
        request.user_ref = 'steve'
        request.options = { 'key' => 'value' }
        request.secondary_offer = other_offer
      end
    end

    let(:builder) { Tinypass::JsonMsgBuilder.new }

    context "with a single purchase request" do
      let(:result) { MultiJson.load(builder.build_purchase_requests([purchase_request])).first }

      it "encodes the purchase request correctly" do
        %w(o1 o2 t v).each do |field|
          expect(result[field]).not_to be_nil
        end

        expect(result['ip']).to eq '1.2.3.4'
        expect(result['uref']).to eq 'steve'
        expect(result['opts']).to eq({ 'key' => 'value' })
      end

      it "encodes the offers correctly" do
        %w(pos pol).each do |field|
          expect(result['o1'][field]).not_to be_nil # yes, we're only currently testing the primary offer
        end

        expect(result['o1']['rid']).to eq 'Premium-Content'
        expect(result['o1']['rnm']).to eq 'Site wide premium content access'
        expect(result['o1']['rurl']).to eq 'http://resource.com'
        expect(result['o1']['tags']).to eq ['tag', 'another tag', 'a third tag']
      end

      it "encodes price options correctly" do
        %w(opt0 opt1).each do |field|
          expect(result['o1']['pos'][field]).not_to be_nil
        end

        po_result_1 = result['o1']['pos']['opt0'] # yes, we're only currently testing the first price option

        expect(po_result_1['price']).to eq '.50'
        expect(po_result_1['exp']).to eq '24 hours'
        expect(po_result_1['caption']).to eq 'Special offer!'
        expect(po_result_1['sd']).to eq 123456789
        expect(po_result_1['ed']).to eq 987654321
        expect(po_result_1['splits']).to eq ["taavo@dd9.com=0.5", "bob@example.org=0.1"]
      end
    end
  end
end