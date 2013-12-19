require 'sawyer'
require 'dotide/arguments'
require 'dotide/configurable'

module Dotide

  # Client for the Dotide API
  #
  # @see http://developer.dotide.com
  class Client

    include Dotide::Configurable

    # Header keys that can be passed in options hash to {#get},{#head}
    CONVENIENCE_HEADERS = Set.new [:accept, :content_type]

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Dotide::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Dotide.instance_variable_get(:"@#{key}"))
      end

      # login_from_netrc unless user_authenticated? || application_authenticated?
    end

    # Compares client options to a Hash of requested options
    #
    # @param opts [Hash] Options to compare with current client options
    # @return [Boolean]
    def same_options?(opts)
      opts.hash == options.hash
    end

  end
end
