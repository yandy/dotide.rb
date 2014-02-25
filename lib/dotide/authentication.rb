module Dotide

  # Authentication methods for {Dotide::Client}
  module Authentication

    # Indicates if the client was supplied  Basic Auth
    # username and client_secret
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def basic_authenticated?
      !!(@client_id && @client_secret)
    end

    # Indicates if the client was supplied an OAuth
    # access token
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def token_authenticated?
      !!@access_token
    end

    # Indicates if the client was supplied an OAuth
    # access token or Basic Auth username and client_secret
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def user_authenticated?
      basic_authenticated? || token_authenticated?
    end

  end
end
