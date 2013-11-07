module Tinypass
  class HtmlWidget
    def create_button_html(request)
      options = request.options.dup || {}
      rid = request.primary_offer.resource.rid
      builder = ClientBuilder.new
      rdata = builder.build_purchase_request(request).gsub('"', '\"')

      html = "<tp:request type=\"purchase\" rid=\"#{ rid }\"" <<
        " url=\"#{ Config.endpoint + Config::CONTEXT }\"" <<
        " rdata=\"#{ rdata }\" aid=\"#{ Tinypass.aid }\"" <<
        " cn=\"#{ Config.token_cookie_name }\" v=\"#{ Config::VERSION }\""

      html << " oncheckaccess=\"#{ request.callback }\"" if request.callback

      if options['button.html']
        custom = options['button.html'].gsub('"', '&quot;')
        html << " custom=\"#{ custom }\""
      elsif options['button.link']
        link = options['button.link'].gsub('"', '&quot;')
        html << " link=\"#{ link }\""
      end

      html << "></tp:request>"

      html
    end
  end
end