require 'spec_helper.rb'

describe Tinypass::Resource do
  describe "#initialize" do
    it "accepts an rid and a name" do
      resource = Tinypass::Resource.new('rid', 'name')
      expect(resource.rid).to eq 'rid'
      expect(resource.name).to eq 'name'
    end

    it "accepts an rid, name and url" do
      resource = Tinypass::Resource.new('rid', 'name', 'url')
      expect(resource.rid).to eq 'rid'
      expect(resource.name).to eq 'name'
      expect(resource.url).to eq 'url'
    end
  end

  it "can set name" do
    resource = Tinypass::Resource.new('rid', 'name')
    resource.name = 'NEW'
    expect(resource.name).to eq 'NEW'
  end
end