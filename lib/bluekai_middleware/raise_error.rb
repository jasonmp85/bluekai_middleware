# encoding: UTF-8

require 'faraday'

module BlueKaiMiddleware
  # Raises a server or client error depending upon the response status
  class RaiseError < Faraday::Response::Middleware

    class StatusCodeFix < Faraday::Response::Middleware
      SUCCESS_STATUS = 'QUERY_SUCCESS'.freeze

      # Some APIs annoyingly return a 200 status code even though some-
      # thing is wrong with the query. This attempts to detect these
      # responses and changes their status code to a 400.
      def on_complete(env)
        status, body = *env.values_at(:status, :body)

        if status == 200 && body.is_a?(Hash)
          env.status = 400 if body['status'] != SUCCESS_STATUS
        end
      end
    end

    # Inspects the status of the environment and raises an error when
    # necessary
    def on_complete(env)
      status, body = *env.values_at(:status, :body)

      if status >= 400
        type = (status >= 500) ? ServerError : ClientError

        raise type.new(status, body)
      end
    end
  end
end
