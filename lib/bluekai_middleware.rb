# encoding: UTF-8

require 'bluekai_middleware/version'
require 'rack/utils'

# This module contains cross-cutting code useful when interacting with any
# number of BlueKai services.
module BlueKaiMiddleware
  autoload :Authenticate,  'bluekai_middleware/authenticate'
  autoload :LogSubscriber, 'bluekai_middleware/log_subscriber'
  autoload :RaiseError,    'bluekai_middleware/raise_error'

  # Raised when code detects a problem with an HTTP response.
  class HTTPError < StandardError
    # @!attribute status
    #   @return [Fixnum] the status code of the underlying HTTP response
    # @!attribute body
    #   @return [String] the body of the underlying HTTP response
    # @!attribute message
    #   @return [String] a human-readable description of the status code
    attr_reader :status, :body, :url

    # Creates a new HTTPError instance.
    # @param [Fixnum] status the status of the response that threw this error
    # @param [String] body the body of the response that resulted in this error
    def initialize(status = nil, body = nil, url = nil)
      super(Rack::Utils::HTTP_STATUS_CODES[status])
      @status, @body, @url = status, body, url
    end
  end

  # Raised when an HTTP error was caused by the client.
  class ClientError < HTTPError; end

  # Raised when an HTTP error was caused by the server.
  class ServerError < HTTPError; end
end
