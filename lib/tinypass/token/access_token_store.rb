require 'uri'

require 'tinypass/token/access_token.rb'
require 'tinypass/token/token_data.rb'

module Tinypass
  class AccessTokenStore
    attr_reader :tokens, :raw_cookie

    def initialize(config = nil)
      @config = config
      @tokens = AccessTokenList.new
    end

    def load_tokens_from_cookie(cookies, name = nil)
      name ||= Config.token_cookie_name(Tinypass.aid)
      @raw_cookie = cookies.respond_to?(:to_str) ? cookies : cookies[name]

      if @raw_cookie
        @tokens = ClientParser.new.parse_access_tokens(URI.unescape(raw_cookie))
      end
    end

    def get_access_token(rid)
      rid = rid.to_s
      return tokens[rid] if tokens[rid]

      token = AccessToken.new(rid, -1)

      if tokens.size == 0
        token.access_state = AccessState::NO_TOKENS_FOUND
      else
        token.access_state = AccessState::RID_NOT_FOUND
      end

      return token
    end

    def has_token?(rid)
      tokens.contains?(rid.to_s)
    end

    def find_active_token(regexp)
      tokens.each do |token|
        return token if token.rid =~ regexp && !token.expired?
      end

      nil
    end

    protected

    def clean_expired_tokens
      @tokens.dup.each do |token|
        @tokens.delete(token.rid) if token.expired? || (token.metered? && token.trial_dead?)
      end
    end
  end
end