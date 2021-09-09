RpiAuth::Engine.routes.draw do
  # post '/login',
  post '/login', to: redirect('/auth/rpi'), as: 'login'
  get '/auth/callback', to: 'auth#callback', as: 'callback'
  get '/logout', to: 'auth#destroy', as: 'logout'
end
