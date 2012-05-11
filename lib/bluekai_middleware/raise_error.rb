# encoding: UTF-8

module BlueKaiMiddleware
  # Raises a server or client error depending upon the response status
  class RaiseError < Faraday::Response::Middleware
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
