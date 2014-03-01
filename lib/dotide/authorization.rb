require 'dotide/models/access_token'
require 'dotide/collections/access_tokens'

module Dotide
  module Authorization
    def access_tokens
      @_access_tokens ||= Dotide::Collections::AccessTokens.new(self)
    end
  end
end
