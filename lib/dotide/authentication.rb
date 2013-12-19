module Dotide

  # Authentication methods for {Dotide::Client}
  module Authentication

    # Indicates if the client was supplied  Basic Auth
    # username and password
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def basic_authenticated?
      !!(@login && @password)
    end

    # Indicates if the client was supplied an OAuth
    # access token
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def token_authenticated?
      !!(@login && @auth_token)
    end

    # Indicates if the client was supplied an OAuth
    # access token or Basic Auth username and password
    #
    # @see http://developer.dotide.com/cn/api/base/auth.html
    # @return [Boolean]
    def user_authenticated?
      basic_authenticated? || token_authenticated?
    end

    private

    def login_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read netrc_file
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        warn "Error loading credentials from netrc file for #{api_endpoint}"
      else
        self.login = creds.shift
        self.password = creds.shift
      end
    rescue LoadError
      warn "Please install netrc gem for .netrc support"
    end

  end
end
