require 'dotide/models/base'

module Dotide
  module Models

    class Scope < Base
      attr_accessor :permissions, :global, :ids, :tags
    end

    class AccessToken < Base

      attr_accessor :access_token, :scopes

      def initialize(conn, resource, url_root)
        @conn = conn
        @url_root = url_root
        @attrs = {}
        if resource.is_a? Sawyer::Resource
          @attrs[:access_token] = resource.access_token
          @attrs[:scopes] = resource.scopes.map { |sp| Scope.new(conn, sp, url_root) }
          @_persist = true
        elsif resource.is_a? Hash
          @attrs[:scopes] = resource[:scopes].map { |sp| Scope.new(conn, sp, url_root) }
          @_persist = false
        else
          raise ArgumentError
        end
      end

      def url
        if persist?
          "#{url_root}/#{access_token}"
        else
          url_root
        end
      end

      def save
        if persist?
          conn.put(url, hash_attrs)
        else
          conn.post(url, hash_attrs)
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

      private

      def hash_attrs
        ha = {}
        ha[:access_token] = access_token if access_token
        ha[:scopes] = scopes.map { |sp| sp.attrs }
        ha
      end

    end
  end
end
