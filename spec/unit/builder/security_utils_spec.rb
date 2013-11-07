require 'spec_helper'

describe Tinypass::SecurityUtils do
  let(:private_key) { "thestringliteralisexactlyfortych" }

  let(:java_data) { "JavaIsSoFun" }
  let(:encrypted_java_data) { "V3IqZVBH2dQh4uxOMy9BAg~~~mB3lhC3FscKs7p18-N2vtvy6pSDsIyicy77lydm-UGk" }

  let(:json_data) { "{\"aid\":\"MICMICMICX\",\"uid\":\"kjkxrNWUyD\",\"tokens\":[\"{\"ex\":1299043304,\"rid\":53530}\"],\"built\":1298957391760}" }
  let(:encrypted_json_data) { "H1PgAu3LPBqwxFnnIEqG1N70CCRXrYsWL_audQvn1kYcbWEf9RQrA4rKX7qmFDvY_zQq61S8qBTWurpxtMLGPl7aEK86hD6Xkf6K2HxvOmHSKdN7iZ6mEJwyqB9X8b76wHA61qb-5eiERNBp3Nkjmw~~~WvbljkqdoCfCj-U-qjCAdyASh8sIajDSyk0pzkPZlBY" }

  describe "#encrypt" do
    it "produces the expected result for 'java' data" do
      expect(Tinypass::SecurityUtils.encrypt(private_key, java_data)).to eq encrypted_java_data
    end

    it "produces the expected result for json data" do
      expect(Tinypass::SecurityUtils.encrypt(private_key, json_data)).to eq encrypted_json_data
    end
  end

  describe "#decrypt" do
    it "produces the expected result for 'java' data" do
      expect(Tinypass::SecurityUtils.decrypt(private_key, encrypted_java_data)).to eq java_data
    end

    it "produces the expected result for json data" do
      expect(Tinypass::SecurityUtils.decrypt(private_key, encrypted_json_data)).to eq json_data
    end
  end

  describe "#hash_hmac_sha256" do
    it 'produces the expected results' do
      expect(Tinypass::SecurityUtils::hash_hmac_sha256(private_key, '')).to eq "Y8MfdiTQSuLQGAW2aCXvAucxnYCmQGQSr780zffAka0"
      expect(Tinypass::SecurityUtils::hash_hmac_sha256(private_key, 'a')).to eq "QSD2YcjAs_V3Z_-SBWmz3AFQ0jPFJi-j45gcgJMFRQ8"
      expect(Tinypass::SecurityUtils::hash_hmac_sha256(private_key, 'tinypass')).to eq "AxJ7i3CxUPOF0q53YCpNzoewP4hRbqSOhqfQRoRFRF4"
      expect(Tinypass::SecurityUtils::hash_hmac_sha256(private_key, '!@#$%^&*()_+{}|:<>?')).to eq "xRdalr1ZhbUYMBxmYJmhjSZi0D4Z-eTKyt-eGFnQPUY"
      expect(Tinypass::SecurityUtils::hash_hmac_sha256(private_key, 'кирилл')).to eq "iPBDZnvNX0YSy10m6JUoItYZ83nXfPgCQXS76yS7Xo4"
    end
  end
end