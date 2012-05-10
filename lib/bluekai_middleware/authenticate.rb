# encoding: UTF-8

require 'base64'
require 'openssl'

require 'faraday/middleware'

module BlueKaiMiddleware
  # Implements the algorithm described in the confluence document
  # kb.bluekai.com/display/PD/Authentication+and+Authorization to
  # sign requests made to BlueKai services.
  class Authenticate < Faraday::Middleware

    # Construct a new Authenticate middleware. Requires a user key
    # and user private key. If the optional superuser parameter is
    # true, then a bkpid must be included on each call.
    def initialize(app, user_key, private_key, superuser = false)
      super(app)
      @user_key, @private_key, @superuser = user_key, private_key, superuser
    end

    # Calculates the signature (bksig) and adds it and a user key
    # (bkuid) to the outgoing request's query parameters. No
    # computation is performed during the response phase.
    def call(env)
      url     = env[:url]
      context = SigningContext.new(env, @private_key)

      if @superuser && !(url.query_values.has_key?('bkpid') || url.query_values.has_key?('pid'))
        raise 'bkpid or pid required if superuser'
      end

      extra_parameters = {
        bkuid: @user_key,
        bksig: context.signature
      }
      url.query_values = (url.query_values || {}).merge(extra_parameters)

      @app.call(env)
    end

    # Only one Authenticate instance is created per Faraday instance,
    # but each request needs a fresh digest object. This class wraps
    # the context needed to sign each request.
    class SigningContext
      # Creates a new SigningContext. private_key is expected to be
      # a string directly used during signing.
      def initialize(env, private_key)
        @method = env[:method].try(:upcase)
        @body   = env[:body]
        @url    = env[:url]
        @path   = @url.path
        @query  = @url.query_values.sort.map(&:last).map { |s| CGI.escape(s) }

        @key    = private_key
        @digest = OpenSSL::Digest.new('sha256')
      end

      def signature
        data      = [@method.try(:upcase), @path, @query, @body].join
        signature = OpenSSL::HMAC.digest(@digest, @key, data)
        # strict_encode doesn't add a line-break like encode does
        Base64.strict_encode64(signature)
      end
    end
  end
end
