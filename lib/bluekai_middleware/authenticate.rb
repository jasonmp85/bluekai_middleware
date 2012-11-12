# encoding: UTF-8

require 'base64'
require 'openssl'

require 'faraday'

module BlueKaiMiddleware
  # Implements BlueKai's {http://kb.bluekai.com/display/PD/Authentication+and+Authorization
  # signing algorithm} in order to facilitate making authenticated calls to BlueKai web services.
  class Authenticate < Faraday::Middleware
    # Creates a new Authenticate middleware instance.
    # @param [#call] app the next middleware in the chain, or the innermost app
    # @param [String] user_key a BlueKai user's public key, to be included in the params
    # @param [String] private_key a BlueKai user's private key, to be used for signing
    def initialize(app, user_key, private_key)
      super(app)
      @user_key, @private_key = user_key, private_key
    end

    # Calculates the signature (`bksig`) and adds it and a user key (`bkuid`) to the outgoing
    # request's query parameters. No computation is performed during the response phase.
    # @param [Hash] env a hash with details about the request
    # @return [void]
    def call(env)
      url     = env[:url]
      context = SigningContext.new(env, @private_key)

      extra_parameters = {
        bkuid: @user_key,
        bksig: context.signature
      }

      query_hash = Authenticate.query_hash(url)
      query_hash.merge!(extra_parameters)
      Authenticate.build_query(url, query_hash)

      @app.call(env)
    end

    def self.build_query(url, query_hash)
      if self.faraday_version_0_8?
        query = Faraday::Utils.build_query(query_hash.sort_by { |key, value| key.to_s })
        url.query = query
      else
        url.query_values = query_hash
      end
    end

    def self.query_hash(url)
      self.faraday_version_0_8? ? Faraday::Utils.parse_query(url.query) : (url.query_values || {})
    end

    def self.faraday_version_0_8?
      Faraday::VERSION.start_with?('0.8')
    end

    # Only one Authenticate instance is created per Faraday client,
    # but each request needs a fresh digest object. This class wraps
    # the context needed to sign each request.
    class SigningContext
      # @!attribute signature
      #   @return [signature] the calculated signature of this signing context
      attr_reader :signature

      # Creates a new SigningContext.
      # @param [Hash] env a hash with details about the request
      # @param [String] private_key a BlueKai user's private key, to be used for signing
      def initialize(env, private_key)
        @method = (env[:method] || '').upcase
        @body   = env[:body]
        @url    = env[:url]
        @path   = @url.path

        # Returns an {} if the query string is empty(or nil).
        query_hash = Authenticate.query_hash(@url)
        @query  = query_hash.sort.map(&:last).map { |s| CGI.escape(s) }

        @key    = private_key
        @digest = OpenSSL::Digest.new('sha256')
      end

      def signature
        @signature ||= begin
          data      = [@method, @path, @query, @body].join
          signature = OpenSSL::HMAC.digest(@digest, @key, data)
          # strict_encode doesn't add a line-break like encode does
          Base64.strict_encode64(signature)
        end
      end
    end
  end
end
