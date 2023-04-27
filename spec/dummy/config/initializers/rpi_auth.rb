if Rails.env.development?
  RpiAuth.configure do |config|
    config.auth_url = 'http://localhost:9001'
    config.auth_client_id = 'gem-dev'
    config.auth_client_secret = 'secret'
    config.brand = 'codeclub'
    config.host_url = 'http://localhost:3000'
    config.identity_url = 'http://localhost:3002'
    config.user_model = 'User'
    config.bypass_auth = false
  end
end

if Rails.env.test?
  RpiAuth.configure do |config|
    config.auth_url = 'https://auth.example.com'
    config.auth_client_id = 'clientid'
    config.auth_client_secret = 'clientsecret'
    config.brand = 'codeclub'
    config.host_url = 'https://example.com'
    config.identity_url = 'https://my.example.com'
    config.user_model = 'User'
    config.bypass_auth = true
  end
end
