require 'dotide/models/base'

module Dotide
  module Models
    class Datapoint < Base

      attr_accessor :t, :v

      def url
        url_root
      end

      def save
        if persist?
          return false
        else
          conn.post(url, attrs)
          @_persist = true
        end
        return true
      rescue Dotide::ClientError => e
        @error = e
        return false
      end
    end
  end
end
