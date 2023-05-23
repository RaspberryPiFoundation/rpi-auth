RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9001'
  config.auth_client_id = 'gem-dev'
  config.auth_client_secret = 'secret'
  config.scope = %w[email force-consent openid profile roles allow-u13-login require-parental-consent]
  config.brand = 'codeclub'
  config.host_url = 'http://localhost:3009'
  config.identity_url = 'http://localhost:3002'
  config.user_model = 'User'

  config.bypass_auth = false

  # In development, the issuer is set in the docker-compose.yml file in the
  # Profile repo.  If you see errors like
  #
  #  (rpi) Authentication failure! Invalid ID token: Issuer does not match
  #
  # then set the issuer here to match the value in the docker-compose file.
  # When Hydra is running, the issue value can also be viewed at
  # http://localhost:9001/.well-known/openid-configuration
  #
  # In staging/production this shouldn't be an issue, as all the hostnames are
  # the same.
  config.issuer = "http://localhost:9001/"
end
