require 'tinypass/builder'
require 'tinypass/gateway'
require 'tinypass/offer'
require 'tinypass/price_option'
require 'tinypass/policies'
require 'tinypass/resource'
require 'tinypass/token'
require 'tinypass/ui'
require 'tinypass/utils'

require 'tinypass/version'

module Tinypass
  extend self
  extend Gateway

  API_ENDPOINT_PROD = "https://api.tinypass.com"
  API_ENDPOINT_SANDBOX = "https://sandbox.tinypass.com"

  attr_accessor :sandbox, :aid, :private_key

  class Config
    VERSION = "2.0.7"
    MSG_VERSION = "2.0p"

    CONTEXT = "/v2"
    REST_CONTEXT = "/r2"

    COOKIE_PREFIX = "__TP_"
    COOKIE_SUFFIX = "_TOKEN"

    attr_accessor :sandbox, :aid, :private_key

    def self.app_prefix(aid)
      COOKIE_PREFIX + aid
    end

    def self.token_cookie_name(aid = Tinypass::aid)
      COOKIE_PREFIX + aid + COOKIE_SUFFIX
    end

    def self.endpoint
      return Tinypass::API_ENDPOINT_DEV if defined?(Tinypass::API_ENDPOINT_DEV)

      Tinypass.sandbox ? Tinypass::API_ENDPOINT_SANDBOX :  Tinypass::API_ENDPOINT_PROD
    end
  end
end