require 'spec_helper'

describe Tinypass::MeterHelper do
  describe ".create_view_based" do
    it "delegates to Meter" do
      Tinypass::Meter.should_receive(:create_view_based).with('meter name', 20, '24 hours').
        and_return('what meter generated')
      expect(Tinypass::MeterHelper.create_view_based('meter name', 20, '24 hours')).to eq 'what meter generated'
    end
  end

  describe ".create_time_based" do
    it "delegates to Meter" do
      Tinypass::Meter.should_receive(:create_time_based).with('meter name', '24 hours', '72 hours').
        and_return('what meter generated')
      expect(Tinypass::MeterHelper.create_time_based('meter name', '24 hours', '72 hours')).to eq 'what meter generated'
    end
  end

  describe ".load_meter_from_cookie" do
    it "returns nil when trial is done" do
      token = build_expired_trial_access_token('RID')
      cookie = build_tinypass_cookie(token, 'RID')

      expect(Tinypass::MeterHelper.load_meter_from_cookie('RID', cookie)).to be_nil
    end

    it "returns nil when rid not found" do
      token = Tinypass::AccessToken.new('RID')
      cookie = build_tinypass_cookie(token, 'RID')

      expect(Tinypass::MeterHelper.load_meter_from_cookie('unknown rid', cookie)).to be_nil
    end

    it "returns the meter when found and active" do
      token = build_active_trial_access_token('RID')
      cookie = build_tinypass_cookie(token, 'RID')
      meter = Tinypass::MeterHelper.load_meter_from_cookie('RID', cookie)

      expect(meter).not_to be_nil
      expect(meter.data.values).to eq token.token_data.values
    end
  end

  describe ".load_meter_from_serialized_data" do
    it "returns nil when trial is done" do
      token = build_expired_trial_access_token('RID')
      meter = Tinypass::Meter.new(token)
      serialized = Tinypass::MeterHelper.serialize(meter)

      expect(Tinypass::MeterHelper.load_meter_from_serialized_data(serialized)).to be_nil
    end

    it "returns the meter when found and active" do
      token = build_active_trial_access_token('RID')
      meter = Tinypass::Meter.new(token)
      serialized = Tinypass::MeterHelper.serialize(meter)
      deserialized = Tinypass::MeterHelper.load_meter_from_serialized_data(serialized)

      expect(deserialized).not_to be_nil
      expect(deserialized.data.values).to eq meter.data.values
    end
  end

  describe "#serialize + #deserialize" do
    it "is symmetrical" do
      meter = Tinypass::MeterHelper.create_view_based('rid', 1, '1 second')
      serialized = Tinypass::MeterHelper.serialize(meter)
      deserialized = Tinypass::MeterHelper.deserialize(serialized)
      expect(meter.data.values).to eq deserialized.data.values
    end
  end

  describe "#serialize_to_json + #deserialize" do
    it "is symmetrical" do
      meter = Tinypass::MeterHelper.create_view_based('rid', 1, '1 second')
      serialized = Tinypass::MeterHelper.serialize_to_json(meter)
      json_string = serialized[5..-1] # skip encoding header
      MultiJson.load(json_string) # if not json, this explodes
      deserialized = Tinypass::MeterHelper.deserialize(serialized)
      expect(meter.data.values).to eq deserialized.data.values
    end
  end

  describe "#generate_cookie_embed_script" do
    it "produces the expected script tag when not locked out" do
      Time.should_receive('now').at_least(:once).and_return(Time.new(2013, 9, 24, 12, 12, 23))
      meter = Tinypass::MeterHelper.create_time_based('name', '1 week', '1 day')
      script_tag = Tinypass::MeterHelper.generate_cookie_embed_script('cookie_name', meter)

      expect(script_tag).to eq "<script>\n        document.cookie='cookie_name=%7Bjax%7DFKb1__OSKlSF7CJ55VTdCksOd3POWF5-bLQ3tDcl6MhKE0YsLW3Mh0t3PabcEnAOOr_RmnEIYP_bgv6ghLMUCoquOlmyWv3IDqvgiJ6UBo0~~~FWrTYDq0ljU3Bsn3Brqz6peZODWs9lZmeRbTkU6o7o8; path=/; expires=2013-12-23 16:12:23 UTC;';\n      </script>"
    end

    it "produces the expected script tag when locked out" do
      Time.should_receive('now').at_least(:once).and_return(Time.new(2013, 9, 24, 12, 12, 23))
      meter = Tinypass::MeterHelper.create_view_based('meter_name', 20, '1 day')
      21.times { meter.increment } # NOTE: probable off-by-one error
      script_tag = Tinypass::MeterHelper.generate_cookie_embed_script('cookie_name', meter)

      expect(script_tag).to eq "<script>\n        document.cookie='cookie_name=%7Bjax%7DyRg67-kFA8Cn0OD9JZhGfYoWyixspCG9n-trTyhzROo1zmFLI4YDk9KIKl4lnGeLBITKfHXaxRhnF7BaKgwuz6vsLbAxfLR3aXahAA9XaiaCGLR-GiCAOlyHHlb5bOUxlbvR1xuqpJqQFSXE5EXQ0A~~~aoKI1vpw7ISE9xV_lR_R0gC54x__3vFrcEiZkLLffcw; path=/; expires=2013-09-25 16:13:23 UTC;';\n      </script>"
    end
  end
end