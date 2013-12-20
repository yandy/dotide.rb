module Dotide
  # Custom error class for rescuing from all GitHub errors
  class Error < StandardError

    # Returns the appropriate Dotide::Error sublcass based
    # on status and response message
    #
    # @param [Hash] response HTTP response
    # @return [Dotide::Error]
    def self.from_response(response)
      status  = response[:status].to_i
      body    = response[:body].to_s
      headers = response[:response_headers]

      if klass =  case status
                  when 400      then Dotide::BadRequest
                  when 401      then Dotide::Unauthorized
                  when 403      then Dotide::Forbidden
                  when 404      then Dotide::NotFound
                  when 406      then Dotide::NotAcceptable
                  when 409      then Dotide::Conflict
                  when 415      then Dotide::UnsupportedMediaType
                  when 422      then Dotide::UnprocessableEntity
                  when 400..499 then Dotide::ClientError
                  when 500      then Dotide::InternalServerError
                  when 501      then Dotide::NotImplemented
                  when 502      then Dotide::BadGateway
                  when 503      then Dotide::ServiceUnavailable
                  when 500..599 then Dotide::ServerError
                  end
        klass.new(response)
      end
    end

    def initialize(response=nil)
      @response = response
      super(build_error_message)
    end

    # Documentation URL returned by the API for some errors
    #
    # @return [String]
    def documentation_url
      data[:documentation_url] if data && data.is_a?(Hash)
    end

    # Array of validation errors
    # @return [Array<Hash>] Error info
    def errors
      if data && data.is_a?(Hash)
        data[:errors] || []
      else
        []
      end
    end

    private

    def data
      @data ||=
        if (body = @response[:body]) && !body.empty?
          if body.is_a?(String) &&
            @response[:response_headers] &&
            @response[:response_headers][:content_type] =~ /json/

            Sawyer::Agent.serializer.decode(body)
          else
            body
          end
        else
          nil
        end
    end

    def response_message
      case data
      when Hash
        data[:message]
      when String
        data
      end
    end

    def response_error
      "Error: #{data[:error]}" if data.is_a?(Hash) && data[:error]
    end

    def response_error_summary
      return nil unless data.is_a?(Hash) && !Array(data[:errors]).empty?

      summary = "\nError summary:\n"
      summary << data[:errors].map do |hash|
        hash.map { |k,v| "  #{k}: #{v}" }
      end.join("\n")

      summary
    end

    def build_error_message
      return nil if @response.nil?

      message =  "#{@response[:method].to_s.upcase} "
      message << @response[:url].to_s + ": "
      message << "#{@response[:status]} - "
      message << "#{response_message}" unless response_message.nil?
      message << "#{response_error}" unless response_error.nil?
      message << "#{response_error_summary}" unless response_error_summary.nil?
      message << " // See: #{documentation_url}" unless documentation_url.nil?
      message
    end
  end

  # Raised on errors in the 400-499 range
  class ClientError < Error; end

  # Raised when GitHub returns a 400 HTTP status code
  class BadRequest < ClientError; end

  # Raised when GitHub returns a 401 HTTP status code
  class Unauthorized < ClientError; end

  # Raised when GitHub returns a 403 HTTP status code
  class Forbidden < ClientError; end

  # Raised when GitHub returns a 403 HTTP status code
  # and body matches 'rate limit exceeded'
  class TooManyRequests < Forbidden; end

  # Raised when GitHub returns a 403 HTTP status code
  # and body matches 'login attempts exceeded'
  class TooManyLoginAttempts < Forbidden; end

  # Raised when GitHub returns a 404 HTTP status code
  class NotFound < ClientError; end

  # Raised when GitHub returns a 406 HTTP status code
  class NotAcceptable < ClientError; end

  # Raised when GitHub returns a 409 HTTP status code
  class Conflict < ClientError; end

  # Raised when GitHub returns a 414 HTTP status code
  class UnsupportedMediaType < ClientError; end

  # Raised when GitHub returns a 422 HTTP status code
  class UnprocessableEntity < ClientError; end

  # Raised on errors in the 500-599 range
  class ServerError < Error; end

  # Raised when GitHub returns a 500 HTTP status code
  class InternalServerError < ServerError; end

  # Raised when GitHub returns a 501 HTTP status code
  class NotImplemented < ServerError; end

  # Raised when GitHub returns a 502 HTTP status code
  class BadGateway < ServerError; end

  # Raised when GitHub returns a 503 HTTP status code
  class ServiceUnavailable < ServerError; end

  # Raised when client fails to provide valid Content-Type
  class MissingContentType < ArgumentError; end
end
