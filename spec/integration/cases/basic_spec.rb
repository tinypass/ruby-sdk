require 'spec_helper'

feature 'Basic Case' do
  let(:store) { Tinypass::AccessTokenStore.new }

  scenario 'single access' do
    token = Tinypass::AccessToken.new('RID1', Time.now.to_i + 1)
    cookies = build_tinypass_cookie(token)
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 1
    expect(store.get_access_token('RID1').access_granted?).to be_true
  end

  scenario 'early expiration' do
    token = Tinypass::AccessToken.new('RID1', Time.now.to_i + 1, Time.now.to_i - 1)
    cookies = build_tinypass_cookie(token)
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 1
    expect(store.get_access_token('RID1').access_granted?).to be_false
  end

  scenario 'all granted' do
    tokens = [
      Tinypass::AccessToken.new('RID1', Time.now.to_i + 1),
      Tinypass::AccessToken.new('RID2', Time.now.to_i + 1),
      Tinypass::AccessToken.new('RID3', Time.now.to_i + 1)
    ]
    cookies = build_tinypass_cookie(tokens)
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 3
    expect(store.get_access_token('RID1').access_granted?).to be_true
    expect(store.get_access_token('RID2').access_granted?).to be_true
    expect(store.get_access_token('RID3').access_granted?).to be_true
  end

  scenario 'all denied' do
    tokens = [
      Tinypass::AccessToken.new('RID1', Time.now.to_i - 1),
      Tinypass::AccessToken.new('RID2', Time.now.to_i - 1),
      Tinypass::AccessToken.new('RID3', Time.now.to_i - 1)
    ]
    cookies = build_tinypass_cookie(tokens)
    store.load_tokens_from_cookie(cookies)

    expect(store.tokens.size).to eq 3
    expect(store.get_access_token('RID1').access_granted?).to be_false
    expect(store.get_access_token('RID2').access_granted?).to be_false
    expect(store.get_access_token('RID3').access_granted?).to be_false
  end
end