require 'spec_helper.rb'

describe Tinypass do
  it "can set and get sandbox" do
    Tinypass.sandbox = true
    expect(Tinypass.sandbox).to be_true
  end

  it "can set and get the aid" do
    Tinypass.aid = 'this is my aid'
    expect(Tinypass.aid).to eq 'this is my aid'
  end

  it "can set and get the private key" do
    Tinypass.private_key = 'this is my private key'
    expect(Tinypass.private_key).to eq 'this is my private key'
  end
end

describe Tinypass::Config do
  it "has the expected version number" do
    expect(Tinypass::Config::VERSION).to eq '2.0.7'
  end

  it "has the expected context" do
    expect(Tinypass::Config::CONTEXT).to eq '/v2'
  end

  describe "#endpoint" do
    after do
      if Tinypass.const_defined?('API_ENDPOINT_DEV')
        Tinypass.send(:remove_const, 'API_ENDPOINT_DEV')
      end
    end

    it "returns the live url when live" do
      Tinypass.sandbox = false
      expect(Tinypass::Config.endpoint).to eq "https://api.tinypass.com"
    end

    it "returns the sandbox url when sandboxed" do
      Tinypass.sandbox = true
      expect(Tinypass::Config.endpoint).to eq "https://sandbox.tinypass.com"
    end

    it "returns the development url if set" do
      Tinypass.const_set('API_ENDPOINT_DEV', 'http://test.com')
      expect(Tinypass::Config.endpoint).to eq 'http://test.com'
    end
  end
end