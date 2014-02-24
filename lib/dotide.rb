require 'dotide/connection'
require 'dotide/default'

# Ruby toolkit for the GitHub API
module Dotide

  class << self
    include Dotide::Configurable

    # API connection based on configured options {Configurable}
    #
    # @return [Dotide::Connection] API wrapper
    def connection
      @connection = Dotide::Connection.new(options) unless defined?(@connection) && @connection.same_options?(options)
      @connection
    end

    # @private
    def respond_to_missing?(method_name, include_private=false); connection.respond_to?(method_name, include_private); end if RUBY_VERSION >= "1.9"
    # @private
    def respond_to?(method_name, include_private=false); connection.respond_to?(method_name, include_private) || super; end if RUBY_VERSION < "1.9"

  private

    def method_missing(method_name, *args, &block)
      return super unless connection.respond_to?(method_name)
      connection.send(method_name, *args, &block)
    end

  end
end

Dotide.setup
