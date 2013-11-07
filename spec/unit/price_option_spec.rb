require 'spec_helper.rb'

describe Tinypass::PriceOption do
  describe "#initialize" do
    it "accepts a price and an access period" do
      option = Tinypass::PriceOption.new('.50', '24 hours')
      expect(option.price).to eq '.50'
      expect(option.access_period).to eq '24 hours'
    end
  end

  it "can set price" do
    option = Tinypass::PriceOption.new('.50', '24 hours')
    option.price = '1.50'
    expect(option.price).to eq '1.50'
  end

  it "can set access period" do
    option = Tinypass::PriceOption.new('.50', '24 hours')
    option.access_period = '1 week'
    expect(option.access_period).to eq '1 week'
  end

  describe "#access_period_in_msecs" do
    it "passes the happy case" do
      option = Tinypass::PriceOption.new('.50', '321 msecs')
      expect(option.access_period_in_msecs).to eq 321
    end
  end

  describe "#access_period_in_secs" do
    it "passes the happy case" do
      option = Tinypass::PriceOption.new('.50', '321 secs')
      expect(option.access_period_in_secs).to eq 321
    end
  end

  it "can set start date" do
    option = Tinypass::PriceOption.new('.50', '24 hours')
    option.start_date_in_secs = 1234
    expect(option.start_date_in_secs).to eq 1234
  end

  it "can set end date" do
    option = Tinypass::PriceOption.new('.50', '24 hours')
    option.end_date_in_secs = 1234
    expect(option.end_date_in_secs).to eq 1234
  end

  it "can set caption" do
    option = Tinypass::PriceOption.new('.50', '24 hours')
    option.caption = 'caption'
    expect(option.caption).to eq 'caption'
  end

  describe "#active?" do
    it "returns true when no start or end date" do
      expect(Tinypass::PriceOption.new('.50', '1 day').active?).to be_true
    end

    it "returns false when before start date" do
      expect(Tinypass::PriceOption.new('.50', '1 day', Time.now.to_i + 10).active?).to be_false
    end

    it "returns false when after end date" do
      expect(Tinypass::PriceOption.new('.50', '1 day', nil, Time.now.to_i - 1).active?).to be_false
    end

    it "returns true when after start and no end" do
      expect(Tinypass::PriceOption.new('.50', '1 day', Time.now.to_i - 1).active?).to be_true
    end

    it "returns true when before end and no start" do
      expect(Tinypass::PriceOption.new('.50', '1 day', nil, Time.now.to_i + 10).active?).to be_true
    end

    it "returns true when between start and end dates" do
      expect(Tinypass::PriceOption.new('.50', '1 day', Time.now.to_i - 1, Time.now.to_i + 10).active?).to be_true
    end

    context "when passed a value" do
      it "uses the value instead of the current time" do
        option = Tinypass::PriceOption.new('.50', '1 day', Time.now.to_i - 1, Time.now.to_i + 10)
        expect(option.active?(Time.now.to_i - 2)).to be_false
      end
    end
  end

  it "can add split pays" do
    price_option = Tinypass::PriceOption.new('.50', '1 day')
    price_option.add_split_pay('email@example.org', '.25')
    price_option.add_split_pay('another_email@another_host.net', '5%')
    expect(price_option.split_pays).not_to be_nil
    expect(price_option.split_pays['email@example.org']).to eq 0.25
    expect(price_option.split_pays['another_email@another_host.net']).to eq 0.05
  end

  describe "#to_s" do
    it "translates the price option as expected" do
      price_option = Tinypass::PriceOption.new('.50', '1 day',
        Date.new(2013, 9, 21).to_time.to_i,
        Date.new(2013, 7, 3).to_time.to_i)
      price_option.add_split_pay('email@example.org', '.25')
      price_option.add_split_pay('another_email@another_host.net', '5%')

      expect(price_option.to_s).to eq "Price:.50\tPeriod:1 day\tTrial Period:1 day\tStart:1379736000:Sat, 21 Sep 2013 00 00 00\tEnd:1372824000:Wed, 03 Jul 2013 00 00 00\tSplit:email@example.org:0.25\tSplit:another_email@another_host.net:0.05"
    end
  end
end