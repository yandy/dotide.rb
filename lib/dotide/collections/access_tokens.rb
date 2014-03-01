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

      def all
        conn.get(url).map do |m|
          model.new(conn, m, url)
        end
      end

      def find_one(id)
        _url = "#{url}/#{id}"
        model.new(conn, conn.get(_url), url)
      end

      def create(data = {})
        model.new(conn, conn.post(url, data), url)
      end

      def build(data = {})
        model.new(conn, data, url)
      end

      def destroy_one(id)
        _url = "#{url}/#{id}"
        conn.delete(_url)
      end
    end
  end
end
