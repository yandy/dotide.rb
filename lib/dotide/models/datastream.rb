require 'dotide/models/base'

module Dotide
  module Models
    class Datastream < Base

      attr_accessor :id, :name, :type, :tags, :properties

      def url
        if persist?
          "#{url_root}/#{id}"
        else
          url_root
        end
      end

      def save
        if persist?
          conn.put(url, attrs)
        else
          conn.post(url, attrs)
          @_persist = true
        end
        return true
      rescue Dotide::ClientError => e
        @error = e
        return false
      end

      def destroy
        conn.delete(url) if persist?
        attrs.clear
      end

      def datapoints
        @_datapoints ||= Dotide::Collection.new(conn, Dotide::Models::Datapoint, "#{url}/datapoints")
      end

    end
  end
end
