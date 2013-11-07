require 'spec_helper'

describe 'Basic Example' do
  before do
    WebMock.allow_net_connect!
    @access_granted = false
    @file = nil

    # basic example code begins here
    Tinypass.sandbox = true
    Tinypass.aid = ENV['TINYPASS_AID'] || 'expected to find tinypass_aid in environment or .env'
    Tinypass.private_key = ENV['TINYPASS_PRIVATE_KEY'] || 'expected to find tinypass_private_key in environment or .env'

    rid = 'unique_resource_id'
    store = Tinypass::AccessTokenStore.new
    store.load_tokens_from_cookie(cookies)
    if store.get_access_token(rid).access_granted?
      # Access granted! Display requested resource to the user.
      @access_granted = true # code for testing
    else
      # Access denied! Proceed with the next steps and display a Tinypass button…

      resource = Tinypass::Resource.new('Premium-Content', 'Site wide premium content access')

      po1 = Tinypass::PriceOption.new('.50', '24 hours')
      po2 = Tinypass::PriceOption.new('.99', '1 week')
      offer = Tinypass::Offer.new(resource, po1, po2)

      purchase_request = Tinypass::PurchaseRequest.new(offer)
      purchase_request.callback = 'myFunction'
      button_html = purchase_request.generate_tag

      # all further code is for testing
      FileUtils.mkdir_p('tmp')
      @file = Tempfile.new(['basic-example-', '.html'], 'tmp')
      @file.write("<html><head>
                    <script type='text/javascript' src='https://code.tinypass.com/tinypass.js'></script>
                  </head><body>#{ button_html }</body></html>")
      @file.close
      visit "/" + File.basename(@file)

      errors = all('.tp-error')
      if errors.any?
        expect(errors.first.text).to eq ''
      end
    end
  end

  after do
    @file.unlink if @file
    WebMock.disable_net_connect!
  end

  context 'access granted' do
    let(:cookies) { build_tinypass_cookie(access_granted_token) }
    let(:access_granted_token) { Tinypass::AccessToken.new('unique_resource_id', Time.now.to_i + 10000) }

    it 'passes' do
      expect(@access_granted).to be_true
    end
  end

  context 'access not granted' do
    let(:cookies) { build_tinypass_cookie(expired_token) }
    let(:expired_token) { Tinypass::AccessToken.new('unique_resource_id', Time.now.to_i - 1) }

    it 'passes', js: true do
      expect(@access_granted).to be_false
      expect(page).to have_css ".tinypass_button"
    end
  end

  context 'token not found' do
    let(:cookies) { {} }

    it 'passes', js: true do
      expect(@access_granted).to be_false
      expect(page).to have_css ".tinypass_button"
    end
  end
end