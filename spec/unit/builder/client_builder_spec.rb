require 'spec_helper'

describe Tinypass::ClientBuilder do
  describe "#initialize" do
    it "uses a JsonMsgBuilder and SecureEncoder by default" do
      Tinypass::JsonMsgBuilder.should_receive(:new)
      Tinypass::SecureEncoder.should_receive(:new)

      Tinypass::OpenEncoder.should_not_receive(:new)

      Tinypass::ClientBuilder.new
    end

    it "uses the OpenEncoder if specified" do
      Tinypass::JsonMsgBuilder.should_receive(:new)
      Tinypass::OpenEncoder.should_receive(:new)

      Tinypass::SecureEncoder.should_not_receive(:new)

      Tinypass::ClientBuilder.new('_?o')
    end
  end
end