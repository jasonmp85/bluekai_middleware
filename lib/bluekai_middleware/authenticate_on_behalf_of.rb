# encoding: UTF-8

require 'base64'
require 'openssl'

require 'faraday'

module BlueKaiMiddleware

  # Implements BlueKai's identification 'on behalf of' credentials
  class AuthenticateOnBehalfOf < Faraday::Middleware
    # Creates a new AuthenticateOnBehalfOf middleware instance.
    # @param [#call] app the next middleware in the chain, or the innermost app
    # @param [String] partner_key a BlueKai user's partner key, to be included in the params
    # @param [String] user_key a BlueKai user's 'acting as' user key, to be included in the params
    def initialize(app, partner_key, user_key)
      super(app)
      @partner_key, @user_key = partner_key, user_key
    end

    # Adds the partner key (`bkpid`) and a user key (`bkaid`) to the outgoing
    # request's query parameters. No computation is performed during either the request or response phases.
    # @param [Hash] env a hash with details about the request
    # @return [void]
    def call(env)
      url     = env[:url]
      params  = Faraday::Utils.parse_query(url.query)

      env[:params] = params
      env[:path]   = url.path

      extra_parameters = {
        bkpid: @partner_key,
        bkaid: @user_key
      }

      new_params = params.merge(extra_parameters)
      url.query  = Faraday::Utils.build_query(new_params.sort_by { |key, value| key.to_s })

      @app.call(env)
    end

  end
end
