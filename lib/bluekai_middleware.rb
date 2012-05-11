require 'bluekai_middleware/version'

module BlueKaiMiddleware
  autoload :Authenticate,  'bluekai_middleware/authenticate'
  autoload :LogSubscriber, 'bluekai_middleware/log_subscriber'

  class HTTPError < StandardError
    attr_reader :status, :body

    def initialize(status = nil, body = nil)
      super(Rack::Utils::HTTP_STATUS_CODES[status])
      @status, @body = status, body
    end
  end

  class ClientError < HTTPError; end   # used for errors caused by client
  class ServerError < HTTPError; end   # used for server-side errors
end
