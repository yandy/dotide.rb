module Dotide
  module Models
    class Base
      class << self
        def attr_accessor(*attrs)
          attrs.each do |attribute|
            class_eval do
              define_method attribute do
                @attrs[attribute.to_sym]
              end

              define_method "#{attribute}=" do |value|
                @attrs[attribute.to_sym] = value
              end

              define_method "#{attribute}?" do
                !!@attrs[attribute.to_sym]
              end
            end
          end
        end
      end

      attr_reader :attrs, :conn, :url_root, :error
      alias to_hash attrs

      def initialize(conn, resource, url_root)
        @conn = conn
        @url_root = url_root
        if resource.is_a? Sawyer::Resource
          @attrs = hashie(resource)
          @_persist = true
        elsif resource.is_a? Hash
          @attrs = resource
          @_persist = false
        else
          raise ArgumentError
        end
      end

      def url
        raise NotImplementedError
      end

      def save
        raise NotImplementedError
      end

      def destroy
        raise NotImplementedError
      end

      def [](key)
        @attrs[key]
      end

      def []=(key, value)
        @attrs[key] = value
      end

      def persist?
        !!@_persist
      end

      def hashie(res)
        data = {}
        res.attrs.each do |k, v|
          if v.is_a? Sawyer::Resource
            data[k] = hashie(v)
          else
            data[k] = v
          end
        end
        return data
      end

    end
  end
end
