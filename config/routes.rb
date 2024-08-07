# frozen_string_literal: true

Rails.application.routes.draw do
  # Dummy routes. These routes are never reached in the app, as Omniauth
  # intercepts it via Rack middleware before it reaches Rails, however adding
  # them allows us to use rpi_auth_login_path helpers etc.
  post RpiAuth::Engine::LOGIN_PATH, as: :rpi_auth_login
  post RpiAuth::Engine::LOGIN_PATH, as: :rpi_auth_signup, params: { login_options: 'force_signup' }

  get RpiAuth::Engine::CALLBACK_PATH, to: 'rpi_auth/auth#callback', as: 'rpi_auth_callback'
  get RpiAuth::Engine::LOGOUT_PATH, to: 'rpi_auth/auth#destroy', as: 'rpi_auth_logout'

  # This route can be used in testing to log in, avoiding the need to interact
  # with shadow root in the RPF global nav.
  get RpiAuth::Engine::TEST_PATH, to: 'rpi_auth/test#show', as: 'rpi_auth_test' if RpiAuth::Engine::ENABLE_TEST_PATH
end
