# frozen_string_literal: true

module RpiAuth
  class Configuration
    using ::RpiAuthBypass

    attr_writer :auth_token_url, :issuer

    attr_accessor :auth_client_id,
                  :auth_client_secret,
                  :auth_url,
                  :brand,
                  :bypass_auth,
                  :client_auth_method,
                  :host_url,
                  :identity_url,
                  :response_type,
                  :scope,
                  :success_redirect,
                  :user_model

    def initialize
      @brand = 'raspberrypi-org'
      @bypass_auth = false
      @response_type = :code
      @client_auth_method = :basic
    end

    def enable_auth_bypass
      return unless bypass_auth

      OmniAuth.config.enable_rpi_auth_bypass
    end

    def disable_auth_bypass
      OmniAuth.config.disable_rpi_auth_bypass
    end

    def auth_token_url
      @auth_token_url || auth_url
    end

    def authorization_endpoint
      raise ArgumentError, 'No auth_url has been set yet' unless auth_url

      @authorization_endpoint ||= URI.parse(auth_url).merge('/oauth2/auth')
    end

    def issuer
      @issuer ||= token_endpoint.merge('/').to_s
    end

    def jwks_uri
      @jwks_uri ||= token_endpoint.merge('/.well-known/jwks.json')
    end

    def token_endpoint
      raise ArgumentError, 'No auth_token_url or auth_url has been set yet' unless auth_token_url

      @token_endpoint ||= URI.parse(auth_token_url).merge('/oauth2/token')
    end
  end
end
