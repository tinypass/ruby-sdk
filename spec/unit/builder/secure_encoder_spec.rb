require 'spec_helper'

describe Tinypass::SecureEncoder do
  let(:encoder) { Tinypass::SecureEncoder.new(private_key) }
  let(:private_key) { 'private key' }
  let(:message) { 'a string'}

  describe '#encode' do
    it 'passes through to SecurityUtils' do
      Tinypass::SecurityUtils.should_receive(:encrypt).with(private_key, message).and_return 'encrypted'

      expect(encoder.encode(message)).to eq 'encrypted'
    end
  end

  describe '#decode' do
    it 'passes through to SecurityUtils' do
      Tinypass::SecurityUtils.should_receive(:decrypt).with(private_key, message).and_return 'decrypted'

      expect(encoder.decode(message)).to eq 'decrypted'
    end
  end
end