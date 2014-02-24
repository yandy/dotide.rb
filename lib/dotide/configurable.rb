module Dotide

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute api_endpoint
    #   @return [String] Base URL for API requests. default: https://api.dotide.com/
    # @!attribute connection_options
    #   @see https://github.com/lostisland/faraday
    #   @return [Hash] Configure connection options for Faraday
    # @!attribute client_id
    #   @return [String] Dotide client id of a database
    # @!attribute access_token
    #   @return [String] OAuth2 access token for authentication
    # @!attribute middleware
    #   @see https://github.com/lostisland/faraday
    #   @return [Faraday::Builder] Configure middleware for Faraday
    # @!attribute netrc
    #   @return [Boolean] Instruct Dotide to get credentials from .netrc file
    # @!attribute netrc_file
    #   @return [String] Path to .netrc file. default: ~/.netrc
    # @!attribute [w] client_secret
    #   @return [String] Dotide client_secret of a database
    # @!attribute proxy
    #   @see https://github.com/lostisland/faraday
    #   @return [String] URI for proxy server
    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.
    # @!attribute web_endpoint
    #   @return [String] Base URL for web URLs. default: https://dotide.com/

    attr_accessor :connection_options, :access_token,
                  :middleware, :netrc, :netrc_file, :client_id,
                  :proxy, :user_agent, :default_media_type
    attr_writer :client_secret, :web_endpoint, :api_endpoint

    class << self

      # List of configurable keys for {Dotide::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :api_endpoint,
          :connection_options,
          :default_media_type,
          :client_id,
          :access_token,
          :middleware,
          :netrc,
          :netrc_file,
          :client_secret,
          :proxy,
          :user_agent,
          :web_endpoint
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Dotide::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Dotide::Default.options[key])
      end
      self
    end
    alias setup reset!

    def api_endpoint
      File.join(@api_endpoint, "")
    end

    # Base URL for generated web URLs
    #
    # @return [String] Default: https://dotide.com/
    def web_endpoint
      File.join(@web_endpoint, "")
    end

    def netrc?
      !!@netrc
    end

    private

    def options
      Hash[Dotide::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end
