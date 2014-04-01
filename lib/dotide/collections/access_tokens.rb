module Dotide
  module Collections
    class AccessTokens

      attr_reader :conn, :model, :url

      def initialize(conn)
        raise 'Database need to be setted!' unless conn.database
        raise 'Need basic authentication' unless conn.basic_authenticated?
        @conn = conn
        @model = Dotide::Models::AccessToken
        @url = '/access_tokens'
      end

      # List all access tokens for the authenticated database
      # @return [Array<Dotide::Models::AccessToken>]
      def all
        conn.get(url).map do |m|
          model.new(conn, m, url)
        end
      end

      # Fetch an access token by access_token string
      # @param id [String] The 'access_token' string
      # @return [Dotide::Models::AccessToken]
      def find_one(id)
        _url = "#{url}/#{id}"
        model.new(conn, conn.get(_url), url)
      end

      # Create an access token
      # @params scopes [Array<Hash>] scopes of an access token
      # @return [Dotide::Models::AccessToken]
      # @see http://developer.dotide.com/docs/refs/basics/auth.html#para-2
      def create(data = {})
        model.new(conn, conn.post(url, data), url)
      end

      # Build an access token instance and not save to Dotide Server
      # @params scopes [Array<Hash>] scopes of an access token
      # @return [Dotide::Models::AccessToken]
      # @see http://developer.dotide.com/docs/refs/basics/auth.html#para-2
      def build(data = {})
        model.new(conn, data, url)
      end

      # Destroy an existed access token
      # @param id [String] The 'access_token' string
      def destroy_one(id)
        _url = "#{url}/#{id}"
        conn.delete(_url)
      end
    end
  end
end
