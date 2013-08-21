# encoding: UTF-8

require 'active_support'

module BlueKaiMiddleware
  # LogSubscriber is an object meant to consume notifications produced by an instance of
  # `FaradayMiddleware::Instrumentation` (from {https://github.com/pengwynn/faraday_middleware
  # faraday_middleware}).
  #
  # To register this class for use, create an initializer with a line like:
  # ```ruby
  # BlueKaiMiddleware::LogSubscriber.attach_to :faraday
  # ```
  #
  # This class is intended to provide a unified logging format for http calls made using Faraday
  # from within Rails.
  class LogSubscriber < ActiveSupport::LogSubscriber
    # Creates a new LogSubscriber.
    # @param [String] name a name to be prepended to each log line
    def initialize(name = 'Faraday')
      super()
      @name        = name
      @odd_or_even = false
    end

    # Emits an info-level log line containing this subscriber's `name` and the duration, HTTP
    # method, and URL of a request.
    # @param [ActiveSupport::Notifications::Event] event an event encapsulating the request
    # @return [void]
    def request(event)
      env     = event.payload
      name    = '%s %s (%.1fms)' % [@name, env[:method].to_s.upcase, event.duration]
      request = env[:url].to_s

      if odd?
        name     = color(name, CYAN, true)
        request  = color(request,  nil, true)
      else
        name     = color(name, MAGENTA, true)
      end

      info "  #{name}  #{request}"
    end

    private
      def odd?
        @odd_or_even = !@odd_or_even
      end
    end
end
