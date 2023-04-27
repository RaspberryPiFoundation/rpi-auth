Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount RpiAuth::Engine, at: '/rpi_auth'

  root to: 'home#show'

  get '/:slug', to: 'home#show'
end
