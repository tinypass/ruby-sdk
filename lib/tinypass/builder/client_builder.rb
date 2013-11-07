module Tinypass
  class ClientBuilder
    TYPE_JSON = 'j'

    ENCODING_AES = 'a'
    ENCODING_OPEN = 'o'

    STD_ENC = "{jax}"
    ZIP_ENC = "{jzx}"
    OPEN_ENC = "{jox}"

    def initialize(settings = '')
      @private_key = Tinypass.private_key
      @mask = '{'

      @builder = JsonMsgBuilder.new
      @mask << TYPE_JSON

      if settings[2] == ENCODING_OPEN
        @encoder = OpenEncoder.new
        @mask << ENCODING_OPEN
      else
        @encoder = SecureEncoder.new(@private_key)
        @mask << ENCODING_AES
      end

      @mask << 'x}'
    end

    def build_access_tokens(tokens)
      tokens = AccessTokenList.new(tokens) if tokens.kind_of?(AccessToken)
      @mask + @encoder.encode(@builder.build_access_tokens(tokens))
    end

    def build_purchase_request(requests)
      requests = Array(requests)
      @mask + @encoder.encode(@builder.build_purchase_requests(requests))
    end
  end
end