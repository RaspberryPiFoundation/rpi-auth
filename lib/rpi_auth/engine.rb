# frozen_string_literal: true

require 'omniauth-rpi'

module RpiAuth
  class Engine < ::Rails::Engine
    isolate_namespace RpiAuth

    using ::RpiAuthBypass

    initializer 'RpiAuth.set_logger' do
      OmniAuth.config.logger = Rails.logger
    end

    initializer 'RpiAuth.bypass_auth' do
      RpiAuth.configuration.enable_auth_bypass
    end

    initializer 'RpiAuth.add_middleware' do |app|
      app.middleware.use OmniAuth::Builder do
        provider(
          OmniAuth::Strategies::Rpi,
          RpiAuth.configuration.auth_client_id,
          RpiAuth.configuration.auth_client_secret,
          scope: RpiAuth.configuration.scope,
          callback_path: '/rpi_auth/auth/callback',
          client_options: {
            site: RpiAuth.configuration.auth_url,
            authorize_url: "#{RpiAuth.configuration.auth_url}/oauth2/auth",
            token_url: "#{RpiAuth.configuration.auth_token_url || RpiAuth.configuration.auth_url}/oauth2/token"
          },
          authorize_params: { brand: RpiAuth.configuration.brand }
        )

        OmniAuth.config.on_failure = RpiAuth::AuthController.action(:failure)
      end
    end
  end
end
