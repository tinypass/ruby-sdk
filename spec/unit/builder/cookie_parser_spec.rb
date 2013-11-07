require 'spec_helper'

describe Tinypass::CookieParser do
  describe '#extract_cookie_value' do
    it "returns the value when only key found" do
      expect(Tinypass::CookieParser.extract_cookie_value('key', 'key=value')).to eq 'value'
    end

    it "returns the value when not formatted" do
      expect(Tinypass::CookieParser.extract_cookie_value('key', 'value')).to eq 'value'
    end

    it "treats empty strings as nil" do
      expect(Tinypass::CookieParser.extract_cookie_value('key', '')).to be_nil
    end

    it "returns nil when key not found" do
      expect(Tinypass::CookieParser.extract_cookie_value('unknown_key', 'key=value')).to be_nil
    end

    it "returns the value when first key" do
      expect(Tinypass::CookieParser.extract_cookie_value('key',
          'key=value; other_key=21; third_key=[CS|v1|27A5]wasdf[C3]; ')).
        to eq 'value'
    end

    it "returns the value when middle key" do
      expect(Tinypass::CookieParser.extract_cookie_value('key',
          'other_key=21; key=value; third_key=[CS|v1|27A5]wasdf[C3]; ')).
        to eq 'value'
    end

    it "returns the value when last key" do
      expect(Tinypass::CookieParser.extract_cookie_value('key',
          'other_key=21; third_key=[CS|v1|27A5]wasdf[C3]; key=value;')).
        to eq 'value'
    end
  end
end