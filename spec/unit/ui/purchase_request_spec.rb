require 'spec_helper.rb'

describe Tinypass::PurchaseRequest do
  let(:resource) { Tinypass::Resource.new('RID1', 0) }
  let(:price_option) { Tinypass::PriceOption.new('.50', '24 hours') }
  let(:other_price_option) { Tinypass::PriceOption.new('.50', '1 week') }
  let(:offer) { Tinypass::Offer.new(resource, price_option, other_price_option) }

  let(:purchase_request) { Tinypass::PurchaseRequest.new(offer) }

  describe "#generate_tag" do
    it "delegates to an HtmlWidget" do
      Tinypass::HtmlWidget.any_instance.should_receive(:create_button_html).with(purchase_request).and_return("generated html")
      html = purchase_request.generate_tag
      expect(html).to eq 'generated html'
    end
  end

  describe "#generate_link" do
    it "returns the expected value" do
      Tinypass::ClientBuilder.any_instance.should_receive(:build_purchase_request).with(purchase_request).and_return("purchase_request_string")
      link = purchase_request.generate_link('return_url', 'cancel_url')
      expect(link).to eq "https://sandbox.tinypass.com/v2/jsapi/auth.js?aid=#{ Tinypass.aid }&r=purchase_request_string"
    end
  end

  it "can set the user ref" do
    purchase_request.user_ref = 'user'
    expect(purchase_request.user_ref).to eq 'user'
  end

  it "can set client_ip" do
    purchase_request.client_ip = '127.0.0.1'
    expect(purchase_request.client_ip).to eq '127.0.0.1'
  end

  it "sets the offer" do
    expect(purchase_request.primary_offer).to eq offer
  end

  it "can set the secondary offer" do
    other_offer = Tinypass::Offer.new(Tinypass::Resource.new('RID2', 0), Tinypass::PriceOption.new('10', '1 year'))
    purchase_request.secondary_offer = other_offer
    expect(purchase_request.secondary_offer).to eq other_offer
  end
end