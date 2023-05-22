# frozen_string_literal: true

require 'omniauth_openid_connect'
require 'rpi_auth_bypass'

module RpiAuth
  class Engine < ::Rails::Engine
    isolate_namespace RpiAuth

    using ::RpiAuthBypass

    initializer 'RpiAuth.set_logger' do
      OmniAuth.config.logger = Rails.logger
    end

    initializer 'RpiAuth.add_middleware' do |app| # rubocop:disable Metrics/BlockLength
      next unless RpiAuth.configuration

      app.middleware.use OmniAuth::Builder do
        provider(
          :openid_connect,
          name: :rpi,
          issuer: RpiAuth.configuration.issuer,
          scope: RpiAuth.configuration.scope,
          callback_path: '/rpi_auth/auth/callback',
          response_type: RpiAuth.configuration.response_type,
          client_auth_method: RpiAuth.configuration.client_auth_method,
          client_options: {
            identifier: RpiAuth.configuration.auth_client_id,
            secret: RpiAuth.configuration.auth_client_secret,
            scheme: RpiAuth.configuration.token_endpoint.scheme,
            host: RpiAuth.configuration.token_endpoint.host,
            port: RpiAuth.configuration.token_endpoint.port,
            authorization_endpoint: RpiAuth.configuration.authorization_endpoint,
            token_endpoint: RpiAuth.configuration.token_endpoint,
            jwks_uri: RpiAuth.configuration.jwks_uri,
            redirect_uri: URI.join(RpiAuth.configuration.host_url, '/rpi_auth/auth/callback'),
          },
          extra_authorize_params: { brand: RpiAuth.configuration.brand },
          allow_authorize_params: [:login_options],
          origin_param: 'returnTo'
        )

        OmniAuth.config.on_failure = RpiAuth::AuthController.action(:failure)

        RpiAuth.configuration.enable_auth_bypass if RpiAuth.configuration.bypass_auth
      end
    end
  end
end
