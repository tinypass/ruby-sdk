require 'spec_helper'

describe "Client: Build and Parse" do
  context "no IP exists" do
    it "can build and parse consistently" do
      list = Tinypass::AccessTokenList.new
      list << Tinypass::AccessToken.new('RID1')
      list << Tinypass::AccessToken.new('RID2')

      builder = Tinypass::ClientBuilder.new
      parser = Tinypass::ClientParser.new

      out = builder.build_access_tokens(list)
      parsed = parser.parse_access_tokens(out)

      parsed.each do |token|
        expect(token.token_data.values).to eq list[token.token_data.rid].token_data.values
      end
    end
  end
end