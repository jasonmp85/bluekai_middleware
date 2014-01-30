# encoding: UTF-8

require 'faraday'

module BlueKaiMiddleware
  # Raises a server or client error depending upon the response status.
  class RaiseError < Faraday::Response::Middleware

    # Inspects the status of the environment and raises a {ServerError} or {ClientError} when
    # appropriate.
    # @param [Hash] env a hash with details about the response
    # @return [void]
    def on_complete(env)
      status, body, url = *env.values_at(:status, :body, :url)

      if status >= 400
        type = (status >= 500) ? ServerError : ClientError

        raise type.new(status, body, url)
      end
    end

    # Attempts to detect _unique_ ways of signaling failure within certain BlueKai services. If it
    # finds one, this middleware will replace the `status` of the current response with `400`.
    #
    # At the moment, this looks for an entry in the body with the key `status`. If the value is not
    # `QUERY_SUCCESS`, the status replacement takes place. This presupposes the body has already
    # been parsed into a Hash from JSON or some other representation.
    class StatusCodeFix < Faraday::Response::Middleware
      # The magic string representing success in various BlueKai responses
      SUCCESS_STATUS = 'QUERY_SUCCESS'.freeze

      # Replaces the `status` of `env` with `400` if the response's body does not have the status
      # `QUERY_SUCCESS`.
      # @param [Hash] env a hash with details about the response
      # @return [void]
      def on_complete(env)
        status, body = *env.values_at(:status, :body)

        if status == 200 && body.is_a?(Hash)
          env[:status] = 400 if body['status'] != SUCCESS_STATUS
        end
      end
    end
  end
end
