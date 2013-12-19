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
    WEB_ENDPOINT = "https://dotide.com".freeze

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

      # Default pagination preference from ENV
      # @return [String]
      def auto_paginate
        ENV['DOTIDE_AUTO_PAGINATE']
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

      # Default GitHub username for Basic Auth from ENV
      # @return [String]
      def login
        ENV['DOTIDE_LOGIN']
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default GitHub password for Basic Auth from ENV
      # @return [String]
      def password
        ENV['DOTIDE_PASSWORD']
      end

      # Default pagination page size from ENV
      # @return [Fixnum] Page size
      def per_page
        page_size = ENV['DOTIDE_PER_PAGE']

        page_size.to_i if page_size
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

      # Default behavior for reading .netrc file
      # @return [Boolean]
      def netrc
        ENV['DOTIDE_NETRC'] || false
      end

      # Default path for .netrc file
      # @return [String]
      def netrc_file
        ENV['DOTIDE_NETRC_FILE'] || File.join(ENV['HOME'].to_s, '.netrc')
      end

    end
  end
end
