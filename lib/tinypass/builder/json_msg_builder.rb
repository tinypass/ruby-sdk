require 'multi_json'

module Tinypass
  class JsonMsgBuilder
    def parse_access_tokens(json_string)
      json_data = MultiJson.load(json_string)

      # 1.0 tokens can't be parsed in this version
      return AccessTokenList.new([]) if json_data.respond_to?(:has_key?) && json_data.has_key?('tokens')

      access_tokens = []
      Array(json_data).each do |json_datum|
        next if json_datum['rid'].to_s.empty?

        token_data = TokenData.new(json_datum)
        access_tokens << AccessToken.new(token_data)
      end

      AccessTokenList.new(access_tokens)
    end

    def build_access_tokens(list)
      tokens = []

      list.each do |token|
        tokens << token.token_data.values
      end

      MultiJson.dump(tokens)
    end

    def build_access_token(token)
      MultiJson.dump(token.token_data.values)
    end

    def build_purchase_requests(requests)
      data = []

      requests.each do |request|
        data << build_purchase_request(request)
      end

      MultiJson.dump(data)
    end

    private

    def build_purchase_request(request)
      data = {
        o1: build_offer(request.primary_offer),
        t: Time.now.to_i,
        v: Config::MSG_VERSION,
        cb: request.callback
      }

      data[:ip] = request.client_ip if request.client_ip
      data[:uref] = request.user_ref if request.user_ref
      data[:opts] = request.options if request.options && request.options.any?
      data[:o2] = build_offer(request.secondary_offer) if request.secondary_offer

      data
    end

    def build_offer(offer)
      data = {
        rid: offer.resource.rid,
        rnm: offer.resource.name,
        rurl: offer.resource.url,
        pos: build_price_options(offer.pricing.price_options),
        pol: build_policies(offer.policies)
      }

      data[:tags] = offer.tags if offer.tags

      data
    end

    def build_price_options(price_options)
      data = {}

      price_options.each_with_index do |price_option, i|
        key = "opt#{ i }"
        data[key] = build_price_option(price_option)
      end

      data
    end

    def build_price_option(price_option)
      data = {
        price: price_option.price || '',
        exp: price_option.access_period || '',
        caption: price_option.caption || ''
      }

      if price_option.start_date_in_secs && price_option.start_date_in_secs > 0
        data[:sd] = price_option.start_date_in_secs
      end

      if price_option.end_date_in_secs && price_option.end_date_in_secs > 0
        data[:ed] = price_option.end_date_in_secs
      end

      if price_option.split_pays.any?
        data[:splits] = price_option.split_pays.map { |email, amount| "#{ email }=#{ amount }" }
      end

      data
    end

    def build_policies(policies)
      policies.map { |policy| policy.to_hash }
    end
  end
end