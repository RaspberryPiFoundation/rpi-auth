RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9001'
  config.auth_client_id = 'gem-dev'
  config.auth_client_secret = 'secret'
  config.brand = 'codeclub'
  config.host_url = 'http://localhost:3000'
  config.identity_url = 'http://localhost:3002'
  config.user_model = 'User'
end
