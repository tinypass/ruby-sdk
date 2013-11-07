require 'rest_client'
require 'uri'
require 'ostruct'

module Tinypass
  module Gateway
    extend self

    def fetch_access_detail(rid, user_ref)
      params = { rid: rid, user_ref: user_ref }
      response = get('access', params)

      return unless response

      AccessDetails.new(MultiJson.load(response))
    end

    def fetch_access_details(params)
      pagesize = params.delete(:pagesize) || params.delete("pagesize") || 500
      params[:pagesize] = pagesize
      response = get('access/search', params)

      return [] unless response

      PagedList.new(MultiJson.load(response))
    end

    def fetch_subscription_details(params)
      response = get('subscription/search', params)

      MultiJson.load(response)
    end

    def cancel_subscription(params)
      post('subscription/cancel', params)
    end

    def revoke_access(params)
      post('access/revoke', params)
    end

    private

    def get(action, params)
      url = build_url(action, params)
      headers = build_authenticated_headers('GET', url)
      full_url = Config.endpoint + url

      RestClient.get(full_url, headers)
    rescue RestClient::ResourceNotFound
      nil
    end

    def post(action, params)
      url = build_url(action, params)
      headers = build_authenticated_headers('POST', url)
      full_url = Config.endpoint + url

      RestClient.post(full_url, headers)
    end

    def build_url(url, params)
      "#{ Config::REST_CONTEXT }/#{ url }?#{ URI.encode_www_form(params) }"
    end

    def build_authenticated_headers(http_method, url)
      request_definition = "#{ http_method.upcase } #{ url }"
      signature = "#{ Tinypass.aid }:#{ SecurityUtils.hash_hmac_sha256(Tinypass.private_key, request_definition) }"

      { authorization: signature }
    end

    class AccessDetails < OpenStruct
      def access_granted?
        expires.nil? || expires.to_i >= Time.now.to_i
      end
    end

    class PagedList < OpenStruct
      include Enumerable

      def initialize(parsed_response)
        @list = []
        raw_access_details = parsed_response.delete('data')

        raw_access_details.each do |d|
          @list << AccessDetails.new(d)
        end

        super(parsed_response)
      end

      def each(&block)
        @list.each(&block)
      end
    end
  end
end