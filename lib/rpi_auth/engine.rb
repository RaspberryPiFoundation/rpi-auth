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
      if RpiAuth.configuration.bypass_auth == true
        OmniAuth.config.add_rpi_mock(
          uid: 'b6301f34-b970-4d4f-8314-f877bad8b150',
          info: {
            email: 'web@raspberrypi.org',
            name: 'Digital Products Team',
            nickname: 'DP',
            image: 'https://static.raspberrypi.org/files/accounts/default-avatar.jpg'
          },
          extra: {
            raw_info: {
              name: 'Digital Products Team',
              nickname: 'DP',
              email: 'web@raspberrypi.org',
              country: 'United Kingdom',
              country_code: 'GB',
              postcode: 'SW1A 1AA',
              picture: 'https://static.raspberrypi.org/files/accounts/default-avatar.jpg',
              profile: 'https://my.raspberrypi.org/not/a/real/path'
            }
          }
        )
        OmniAuth.config.enable_rpi_auth_bypass
      end
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
          }
        )

        OmniAuth.config.on_failure = RpiAuth::AuthController.action(:failure)
      end
    end
  end
end
