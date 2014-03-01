module Dotide
  module Collections
    class Datapoints

      attr_reader :conn, :model, :url
      attr_reader :id, :datapoints, :options, :summary

      def initialize(conn, id)
        raise 'Database need to be setted!' unless conn.database
        @conn = conn
        @model = Dotide::Models::Datapoint
        @url = "/datastreams/#{id}/datapoints"
      end

      def find(q={})
        res = conn.get(url, q)
        @id = res.id
        @options = res.options.attrs
        @summary = !!res.summary ? res.summary.attrs : {}
        @datapoints = res.datapoints.map do |m|
          model.new(conn, m, url)
        end
        return self
      end

      def create(data = {})
        if data.is_a? Hash
          return model.new(conn, conn.post(url, data), url)
        elsif data.is_a? Array
          dps = conn.post(url, data)
          return dps.map do |m|
            model.new(conn, m, url)
          end
        end

      end

      def build(data = {})
        model.new(conn, data, url)
      end

      def destroy_all(q = {})
        opts = {query: q}
        conn.delete(url, opts)
      end
    end
  end
end
