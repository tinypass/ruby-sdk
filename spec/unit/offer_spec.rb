require 'spec_helper.rb'

describe Tinypass::Offer do
  let(:resource) { Tinypass::Resource.new('RID1', 0) }
  let(:price_option) { Tinypass::PriceOption.new('.50', '24 hours') }
  let(:other_price_option) { Tinypass::PriceOption.new('.50', '1 week') }

  describe "#initialize" do
    it "accepts a resource and two price options" do
      offer = Tinypass::Offer.new(resource, price_option, other_price_option)
      expect(offer.resource).to eq resource
      expect(offer.pricing.price_options.length).to eq 2
    end
  end

  it "delegates has_active_prices? to pricing" do
    offer = Tinypass::Offer.new(resource, price_option, other_price_option)
    fake_pricing = double(has_active_options?: 'it was delegated')

    offer.stub(:pricing).and_return(fake_pricing)
    expect(offer.has_active_prices?).to eq 'it was delegated'
  end

  it "can set tags" do
    offer = Tinypass::Offer.new(resource, price_option, other_price_option)
    offer.tags << 'one' << 'two' << 'three'
    expect(offer.tags).to include('one')
    expect(offer.tags).to include('two')
    expect(offer.tags).to include('three')
  end
end