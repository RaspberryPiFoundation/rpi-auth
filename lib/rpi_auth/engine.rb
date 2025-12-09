# frozen_string_literal: true

require 'omniauth_openid_connect'
require 'rpi_auth_bypass'

module RpiAuth
  class Engine < ::Rails::Engine
    isolate_namespace RpiAuth

    using ::RpiAuthBypass

    LOGIN_PATH = '/auth/rpi'
    CALLBACK_PATH = '/rpi_auth/auth/callback'
    LOGOUT_PATH = '/rpi_auth/logout'
    FRONTCHANNEL_LOGOUT_PATH = '/rpi_auth/frontchannel_logout'
    TEST_PATH = '/rpi_auth/test'

    ENABLE_TEST_PATH = Rails.env.development? || Rails.env.test?

    initializer 'RpiAuth.set_logger' do
      OmniAuth.config.logger = Rails.logger
    end

    initializer 'RpiAuth.add_middleware' do |app| # rubocop:disable Metrics/BlockLength
      next unless RpiAuth.configuration

      openid_connect_options = {
        name: :rpi,
        setup: RpiAuth.configuration.setup,
        issuer: RpiAuth.configuration.issuer,
        scope: RpiAuth.configuration.scope,
        callback_path: CALLBACK_PATH,
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
          redirect_uri: URI.join(RpiAuth.configuration.host_url, CALLBACK_PATH)
        },
        extra_authorize_params: { brand: RpiAuth.configuration.brand },
        allow_authorize_params: [:login_options],
        origin_param: 'returnTo'
      }

      app.middleware.use OmniAuth::Builder do
        provider(:openid_connect, openid_connect_options)

        OmniAuth.config.on_failure = RpiAuth::AuthController.action(:failure)

        RpiAuth.configuration.enable_auth_bypass if RpiAuth.configuration.bypass_auth
      end
    end
  end
end
