# frozen_string_literal: true

Rails.application.routes.draw do
  # Dummy route. This route is never reached in the app, as Omniauth intercepts
  # it via Rack middleware before it reaches Rails, however adding this route
  # allows us to use rpi_auth_login_path helpers etc.
  post '/auth/rpi', as: :rpi_auth_login

  namespace 'rpi_auth' do
    get '/auth/callback', to: 'auth#callback', as: 'callback'
    get '/logout', to: 'auth#destroy', as: 'logout'
  end
end
