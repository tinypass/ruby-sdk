require 'openssl'
require 'base64'

module Tinypass
  module SecurityUtils
    extend self

    DELIM = '~~~'

    def encrypt(key, data)
      original_key = key
      key = prepare_key(key)

      cipher = OpenSSL::Cipher.new('AES-256-ECB')
      cipher.encrypt
      cipher.key = key
      encrypted = cipher.update(data) + cipher.final

      safe = url_ensafe(encrypted)
      safe + DELIM + hash_hmac_sha256(original_key, safe)
    end

    def decrypt(key, data)
      cipher_text, hmac_text = data.split(DELIM)
      check_hmac!(key, cipher_text, hmac_text) if hmac_text
      key = prepare_key(key)
      cipher_text = url_desafe(cipher_text)

      cipher = OpenSSL::Cipher.new('AES-256-ECB')
      cipher.decrypt
      cipher.key = key
      cipher.update(cipher_text) + cipher.final
    end

    def hash_hmac_sha256(key, data)
      digest = OpenSSL::Digest::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, key, data)
      url_ensafe(hmac)
    end

    private

    def url_ensafe(data)
      base64 = Base64.urlsafe_encode64(data)
      base64.sub!(/(=+)$/, '')
      base64
    end

    def url_desafe(data)
      modulus = data.length % 4
      data << '=' * (4 - modulus) if modulus != 0
      Base64.urlsafe_decode64(data)
    end

    def prepare_key(key)
      key = key.slice(0, 32) if key.length > 32
      key = key.ljust(32, 'X') if key.length < 32
      key
    end

    def check_hmac!(key, cipher_text, hmac_text)
      if hash_hmac_sha256(key, cipher_text) != hmac_text
        raise ArgumentError.new('Could not parse message invalid hmac')
      end
    end
  end
end