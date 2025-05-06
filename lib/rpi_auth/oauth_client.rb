# frozen_string_literal: true

require 'oauth2/client'
require 'oauth2/access_token'

module RpiAuth
  class OauthClient
    attr_reader :client

    def initialize
      @client = OAuth2::Client.new(
        RpiAuth.configuration.auth_client_id,
        RpiAuth.configuration.auth_client_secret,
        site: RpiAuth.configuration.auth_token_url,
        token_url: RpiAuth.configuration.token_endpoint.path,
        authorize_url: RpiAuth.configuration.authorization_endpoint.path
      )
    end

    def refresh_credentials(**credentials)
      new_credentials = if RpiAuth.configuration.bypass_auth
                          credentials.merge(expires_at: 1.hour.from_now)
                        else
                          OAuth2::AccessToken.from_hash(client, credentials).refresh.to_hash
                        end

      {
        access_token: new_credentials[:access_token],
        refresh_token: new_credentials[:refresh_token],
        expires_at: new_credentials[:expires_at].to_i
      }
    end
  end
end
