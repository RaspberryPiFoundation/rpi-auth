# frozen_string_literal: true

Rails.application.routes.draw do
  # Dummy routes. These routes are never reached in the app, as Omniauth
  # intercepts it via Rack middleware before it reaches Rails, however adding
  # them allows us to use rpi_auth_login_path helpers etc.
  post '/auth/rpi', as: :rpi_auth_login, params: { login_options: 'v1_signup' }
  post '/auth/rpi', as: :rpi_auth_signup, params: { login_options: 'force_signup,v1_signup' }

  namespace 'rpi_auth' do
    get '/auth/callback', to: 'auth#callback', as: 'callback'
    get '/logout', to: 'auth#destroy', as: 'logout'
  end
end
