require 'spec_helper'

describe Tinypass::HtmlWidget do
  let(:resource) { Tinypass::Resource.new('RID1', 0) }
  let(:price_option) { Tinypass::PriceOption.new('.50', '24 hours') }
  let(:other_price_option) { Tinypass::PriceOption.new('.50', '1 week') }
  let(:offer) { Tinypass::Offer.new(resource, price_option, other_price_option) }

  let(:purchase_request) do
    request = Tinypass::PurchaseRequest.new(offer)
    request.callback = 'myFunction'
    request
  end

  let(:widget) { Tinypass::HtmlWidget.new }

  describe "#create_button_html" do
    let(:html) { widget.create_button_html(purchase_request) }
    let(:doc) { Nokogiri::XML(html) }
    let(:node) { doc.children.first }

    it "is stringy" do
      expect(html).to respond_to :to_str
    end

    it "produces no unexpected parsing errors" do
      expect(doc.errors.length).to eq 1
      expect(doc.errors.first.message).to eq "Namespace prefix tp on request is not defined" # TODO: fragile
    end

    it "sets the tag name as expected" do
      expect(node.name).to eq 'tp:request'
    end

    it "sets the type attribute" do
      expect(node[:type]).to eq 'purchase'
    end

    it "sets the rid attribute" do
      expect(node[:rid]).to eq 'RID1'
    end

    it "sets the url attribute" do
      expect(node[:url]).to eq 'https://sandbox.tinypass.com/v2'
    end

    it "sets the aid attribute" do
      expect(node[:aid]).to eq 'TEST_AID'
    end

    it "sets the cn attribute" do
      expect(node[:cn]).to eq '__TP_TEST_AID_TOKEN'
    end

    it "sets the v attribute" do
      expect(node[:v]).to eq '2.0.7'
    end

    it "starts the rdata correctly" do
      expect(node[:rdata]).to start_with '{jax}'
    end

    it "has an rdata hmac delimiter" do
      expect(node[:rdata]).to include '~~~'
    end

    it "sets the callback" do
      expect(node[:oncheckaccess]).to eq 'myFunction'
    end

    context "options" do
      context "button.html" do
        let(:purchase_request) { Tinypass::PurchaseRequest.new(offer, "button.html" => 'custom html "goes" here') }

        it "sets and html_encodes the value" do
          expect(node[:custom]).to eq 'custom html "goes" here'
        end
      end

      context "button.html" do
        let(:purchase_request) { Tinypass::PurchaseRequest.new(offer, "button.link" => 'custom link "goes" here') }

        it "sets and html_encodes the value" do
          expect(node[:link]).to eq 'custom link "goes" here'
        end
      end
    end
  end
end