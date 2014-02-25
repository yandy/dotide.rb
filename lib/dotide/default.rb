require 'dotide/response/raise_error'
require 'dotide/response/feed_parser'
require 'dotide/version'

module Dotide

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_ENDPOINT = "http://api.dotide.com".freeze

    # Default User Agent header string
    USER_AGENT   = "Dotide Ruby Gem #{Dotide::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   = "application/json"

    # Default WEB endpoint
    WEB_ENDPOINT = "http://dotide.com".freeze

    # Default Faraday middleware stack
    MIDDLEWARE = Faraday::Builder.new do |builder|
      builder.use Dotide::Response::RaiseError
      builder.use Dotide::Response::FeedParser
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Dotide::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['DOTIDE_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        ENV['DOTIDE_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default Dotide client_id for Basic Auth from ENV
      # @return [String]
      def client_id
        ENV['DOTIDE_CLIENT_ID']
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default Dotide client_secret for Basic Auth from ENV
      # @return [String]
      def client_secret
        ENV['DOTIDE_CLIENT_SECRET']
      end

      # Default Dotide auth_token for Token Auth from ENV
      # @return [String]
      def access_token
        ENV['DOTIDE_ACCESS_TOKEN']
      end

      # Default Dotide database from ENV
      # @return [String]
      def database
        ENV['DOTIDE_DATABASE']
      end

      # Default proxy server URI for Faraday connection from ENV
      # @return [String]
      def proxy
        ENV['DOTIDE_PROXY']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['DOTIDE_USER_AGENT'] || USER_AGENT
      end

      # Default web endpoint from ENV or {WEB_ENDPOINT}
      # @return [String]
      def web_endpoint
        ENV['DOTIDE_WEB_ENDPOINT'] || WEB_ENDPOINT
      end

    end
  end
end
