require 'dotide/models/access_token'
require 'dotide/collections/access_tokens'

module Dotide

  # Authorization methods for {Dotide::Connection}
  module Authorization

    # Return the {Dotide::Collections::AccessTokens} of current {Dotide::Connection}
    # @return [Dotide::Collections::AccessTokens]
    def access_tokens
      @_access_tokens ||= Dotide::Collections::AccessTokens.new(self)
    end
  end
end
