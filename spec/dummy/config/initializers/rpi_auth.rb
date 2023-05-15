RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9001'
  config.auth_client_id = 'gem-dev'
  config.auth_client_secret = 'secret'
  config.scope = %w[email force-consent openid profile roles allow-u13-login require-parental-consent]
  config.brand = 'codeclub'
  config.host_url = 'http://localhost:3009'
  config.identity_url = 'http://localhost:3002'
  config.user_model = 'User'

  # Profile is running in docker, so we need to set this manually.  This
  # shouldn't be needed elsewhere, unless you're getting errors saying:
  #   Invalid ID token: Issuer does not match
  config.issuer = "http://host.docker.internal:9001/"
end
