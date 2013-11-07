module Tinypass
  class SecureEncoder
    def initialize(private_key)
      @private_key = private_key
    end

    def encode(message)
      Tinypass::SecurityUtils::encrypt(@private_key, message)
    end

    def decode(message)
      Tinypass::SecurityUtils::decrypt(@private_key, message)
    end
  end
end