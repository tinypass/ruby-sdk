module Tinypass
  class ClientParser
    DATA_BLOCK_START_SIGNATURE = /{\w\w\w}/

    def parse_access_tokens(message)
      tokens = []
      blocks = split_message_string(message)

      blocks.each do |block|
        block_data = setup_implementations(block)
        list = @parser.parse_access_tokens(@encoder.decode(block_data))
        tokens += list.tokens
      end

      AccessTokenList.new(tokens)
    end

    private

    def split_message_string(message)
      start = -1
      list = []

      message.scan(DATA_BLOCK_START_SIGNATURE) do
        list << message[start...Regexp.last_match.begin(0)] if start >= 0
        start = Regexp.last_match.begin(0)
      end
      list << message[start..-1] if start >= 0

      list
    end

    def setup_implementations(block)
      block = ClientBuilder::STD_ENC if block.empty?

      @parser = JsonMsgBuilder.new

      if block[2] == ClientBuilder::ENCODING_OPEN
        @encoder = OpenEncoder.new
      else
        @encoder = SecureEncoder.new(Tinypass.private_key)
      end

      block.sub!(/^{...}/, '')
      block
    end
  end
end