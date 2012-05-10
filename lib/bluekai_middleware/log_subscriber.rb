# encoding: UTF-8

require 'active_support/log_subscriber'

module BlueKaiMiddleware
  # BlueKaiMiddleware::LogSubscriber is an object meant to consume notifications produced
  # by an instance of FaradayMiddleware::Instrumentation (from the faraday_middleware
  # gem).
  #
  # To register this class for use, create an initializer with a line like:
  #
  #   Faraday::LogSubscriber.attach_to :faraday
  #
  # This class is intended to provide a unified logging format for http calls made using
  # Faraday from within Rails.
  class LogSubscriber < ActiveSupport::LogSubscriber
    # Creates a new LogSubscriber. +name+—which defaults to 'Faraday'—will be prepended
    # to each emitted log line.
    def initialize(name = 'Faraday')
      super
      @name        = name
      @odd_or_even = false
    end

    # Emits an info-level log line based on +event+.
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

    def logger
      Rails.logger
    end

    private
      def odd?
        @odd_or_even = !@odd_or_even
      end
    end
end
