require 'spec_helper'

describe Tinypass::ClientParser do
  describe "#parse_access_tokens" do
    let(:fake_builder) { double }
    let(:fake_encoder) { double }

    before do
      Tinypass::JsonMsgBuilder.should_receive(:new).twice.and_return(fake_builder)

      fake_encoder.should_receive(:decode).twice.with('payload').and_return('decoded payload')
      fake_builder.should_receive(:parse_access_tokens).twice.with('decoded payload').and_return(OpenStruct.new(tokens: []))
    end

    it "uses the JsonMsgBuilder and SecureEncoder by default" do
      Tinypass::SecureEncoder.should_receive(:new).twice.and_return(fake_encoder)

      Tinypass::ClientParser.new.parse_access_tokens("???{QQQ}payload{QQQ}payload") # QQQ is intended to be unkonwn, triggering defaults
    end

    it "uses the OpenEncoder if specified" do
      Tinypass::OpenEncoder.should_receive(:new).twice.and_return(fake_encoder)

      Tinypass::ClientParser.new.parse_access_tokens("???{QoQ}payload{QoQ}payload") # the Qs are intended to be unknown, triggering defaults
    end
  end
end