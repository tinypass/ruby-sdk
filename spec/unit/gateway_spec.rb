require 'spec_helper'

describe Tinypass::Gateway do
  describe "#fetch_access_detail" do
    it "returns nil when server returns 404" do
      stub_request(:get, 'https://sandbox.tinypass.com/r2/access?rid=my_rid&user_ref=my_user_ref').to_return(status: 404)
      expect(Tinypass.fetch_access_detail('my_rid', 'my_user_ref')).to be_nil
    end

    context "when server returns data" do
      it "returns an AccessDetails" do
        stub_request(:get, 'https://sandbox.tinypass.com/r2/access?rid=my_rid&user_ref=my_user_ref').
          to_return(status: 200, body: "{}")
        expect(Tinypass.fetch_access_detail('my_rid', 'my_user_ref')).to be_kind_of Tinypass::Gateway::AccessDetails
      end
    end
  end

  describe "#fetch_access_details" do
    it "returns nil when server returns 404" do
      stub_request(:get, "https://sandbox.tinypass.com/r2/access/search?pagesize=500&user_ref=my_user_ref").to_return(status: 404)
      expect(Tinypass.fetch_access_details(user_ref: 'my_user_ref')).to be_empty
    end

    context "when server returns data" do
      it "returns an array of AccessDetails" do
        stub_request(:get, "https://sandbox.tinypass.com/r2/access/search?pagesize=500&user_ref=my_user_ref").
          to_return(status: 200, body: MultiJson.dump(data: [{}]))
        details_array = Tinypass.fetch_access_details(user_ref: 'my_user_ref')
        expect(details_array).not_to be_empty
        expect(details_array.first).to be_kind_of Tinypass::Gateway::AccessDetails
      end
    end
  end

  describe "#fetch_subscription_details" do
    it "returns the json" do
      fake_result = [{ 'key' => 'value' }]

      stub_request(:get, "https://sandbox.tinypass.com/r2/subscription/search?rid=my_rid&user_ref=my_user_ref").
        to_return(status: 200, body: MultiJson.dump(fake_result))

      expect(Tinypass.fetch_subscription_details({user_ref: 'my_user_ref', rid: 'my_rid'})).to eq fake_result
    end
  end

  describe "#cancel_subscription" do
    it "produces the expected request" do
      cancel_request = stub_request(:post, "https://sandbox.tinypass.com/r2/subscription/cancel?rid=my_rid&user_ref=my_user_ref")

      Tinypass.cancel_subscription({user_ref: 'my_user_ref', rid: 'my_rid'})
      expect(cancel_request).to have_been_requested
    end
  end

  describe "#revoke_access" do
    it "produces the expected request" do
      revoke_request = stub_request(:post, "https://sandbox.tinypass.com/r2/access/revoke?refund=true&rid=my_rid&user_ref=my_user_ref")

      Tinypass.revoke_access({user_ref: 'my_user_ref', rid: 'my_rid', refund: true})
      expect(revoke_request).to have_been_requested
    end
  end
end

describe Tinypass::Gateway::AccessDetails do
  describe "#access_granted?" do
    it "returns true when expires not set" do
      expect(Tinypass::Gateway::AccessDetails.new.access_granted?).to be_true
    end

    it "returns true when expires in the future" do
      expect(Tinypass::Gateway::AccessDetails.new(expires: Time.now.to_i + 1000).access_granted?).to be_true
    end

    it "returns false when expires in the past" do
      expect(Tinypass::Gateway::AccessDetails.new(expires: Time.now.to_i - 1).access_granted?).to be_false
    end
  end
end
