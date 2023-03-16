# frozen_string_literal: true

module RpiAuth
  class Configuration
    attr_accessor :auth_client_id,
                  :auth_client_secret,
                  :auth_url,
                  :auth_token_url,
                  :bypass_auth,
                  :host_url,
                  :identity_url,
                  :scope,
                  :success_redirect,
                  :user_model

    def initialize
      @bypass_auth = false
    end
  end
end
