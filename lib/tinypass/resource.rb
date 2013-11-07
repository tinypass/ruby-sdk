module Tinypass
  class Resource
    attr_accessor :name, :url

    def initialize(rid = nil, name = nil, url = nil)
      @rid, @name, @url = rid, name, url
    end

    def rid
      @rid.to_s
    end

    def rid=(value)
      @rid = value.to_s
    end
  end
end