RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9001'
  config.auth_client_id = 'gem-dev'
  config.auth_client_secret = 'secret'
  config.scope = %w[email force-consent openid profile roles allow-u13-login require-parental-consent]
  config.brand = 'codeclub'
  config.host_url = 'http://localhost:3009'
  config.identity_url = 'http://localhost:3002'
  config.session_keys_to_persist = %w[foo bar]
  config.user_model = 'User'

  # Redurect to the next URL
  config.success_redirect = -> { "#{request.env['omniauth.origin']}?#{{ email: current_user.email }.to_query}" }
  config.bypass_auth = false
end
