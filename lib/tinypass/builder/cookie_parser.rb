module Tinypass
  module CookieParser
    extend self

    COOKIE_PARSER = /[^=\s]+=[^=;]*/

    def extract_cookie_value(key, cookies_string)
      return if cookies_string.empty?

      keys_found = false

      cookies_string.scan(COOKIE_PARSER).each do |cookie_string|
        cookie_key, cookie_value = cookie_string.split('=')

        keys_found = true

        return cookie_value if cookie_key == key
      end

      return if keys_found

      cookies_string
    end
  end
end