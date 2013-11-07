module Tinypass
  class AccessTokenList
    include Enumerable

    MAX = 20

    def initialize(input_tokens = nil)
      @tokens_hash = {}
      input_tokens = Array(input_tokens)

      input_tokens.each { |token| self << token }
    end

    def tokens
      @tokens_hash.values
    end
    alias_method :access_tokens, :tokens

    def [](rid)
      @tokens_hash[rid.to_s]
    end

    def <<(token)
      key = token.token_data.rid

      @tokens_hash[key] = token
      shift until size <= MAX

      self[key]
    end
    alias_method :add, :<<

    def push(*args)
      args.each do |token|
        self << token
      end
    end

    def add_all(tokens)
      self.push(*tokens)
    end

    def include?(rid)
      rid = rid.to_s
      @tokens_hash.has_key?(rid)
    end
    alias_method :contains?, :include?

    def each(*args, &block)
      tokens.each(*args, &block)
    end

    def length
      tokens.size
    end
    alias_method :size, :length

    def empty?
      @tokens_hash.empty?
    end

    def delete(rid)
      @tokens_hash.delete(rid)
    end
    alias_method :remove, :delete

    def shift
      delete(@tokens_hash.keys.first)
    end
  end
end