module Tinypass
  class PurchaseRequest
    attr_accessor :primary_offer, :secondary_offer, :options, :callback, :client_ip, :user_ref

    def initialize(offer, options = {})
      @primary_offer, @options = offer, options
    end

    def generate_tag
      widget = HtmlWidget.new
      widget.create_button_html(self)
    end

    def generate_link(return_url, cancel_url)
      self.options['return_url'] = return_url if return_url
      self.options['cancel_url'] = cancel_url if cancel_url

      builder = ClientBuilder.new
      ticket_string = builder.build_purchase_request(self)

      Config.endpoint + Config::CONTEXT + "/jsapi/auth.js?aid=#{ Tinypass.aid }&r=#{ ticket_string }"
    end

    def client_ip=(value)
      value.strip! if value
      @client_ip = value
    end

    def user_ref=(value)
      value.strip! if value
      @user_ref = value
    end
  end
end