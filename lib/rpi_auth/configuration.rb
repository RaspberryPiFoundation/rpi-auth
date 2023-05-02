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
                  :host_url,
                  :identity_url,
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
  end
end
