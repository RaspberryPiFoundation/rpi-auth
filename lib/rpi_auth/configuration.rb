# frozen_string_literal: true

module RpiAuth
  class Configuration
    using ::RpiAuthBypass

    attr_accessor :auth_client_id,
                  :auth_client_secret,
                  :auth_url,
                  :auth_token_url,
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
      @bypass_auth = false
    end

    def enable_auth_bypass
      return unless bypass_auth

      OmniAuth.config.enable_rpi_auth_bypass
    end

    def authorization_endpoint
      @authorization_endpoint ||= URI.parse(auth_url).merge('/oauth2/auth')
    end

    def issuer
      @issuer ||= token_endpoint.merge('/').to_s
    end

    def jwks_uri
      @jwks_uri ||= token_endpoint.merge('/.well-known/jwks.json')
    end

    def token_endpoint
      @token_endpoint ||= URI.parse(auth_token_url || auth_url).merge('/oauth2/token')
    end
  end
end
