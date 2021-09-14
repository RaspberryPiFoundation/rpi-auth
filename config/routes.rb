# frozen_string_literal: true

Rails.application.routes.draw do
  namespace 'rpi_auth' do
    get '/auth/callback', to: 'auth#callback', as: 'callback'
    get '/logout', to: 'auth#destroy', as: 'logout'
  end
end
