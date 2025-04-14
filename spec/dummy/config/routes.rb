Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#show'
  get '/reset-user', to: 'home#reset_user'

  resource :session, only: %i[create]

  # Make sure we don't match auth routes
  get '/*slug', to: 'home#show', constraints: { slug: /(?!(rpi_)?auth\/).*/ }
end
