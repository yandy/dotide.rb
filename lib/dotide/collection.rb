module Dotide
  class Collection

    attr_reader :conn, :model, :url

    def initialize(conn, model, url)
      raise 'Database need to be setted!' unless conn.database
      @conn = conn
      @model = model
      @url = url
    end

    def find(q={})
      conn.get(url, q).map do |m|
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

    def destroy_all(q = {})
      conn.delete(url, q)
    end
  end
end
