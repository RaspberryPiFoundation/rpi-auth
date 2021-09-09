if Rails.env.development?
  RpiAuth.configure do |config|
    config.auth_url = 'http://localhost:9000'
    config.auth_client_id = 'gem-dev'
    config.auth_client_secret = 'secret'
    config.host_url = 'http://localhost:3009'
    config.identity_url = 'http://localhost:3002'
    config.user_model = 'User'
    config.success_redirect = '/'
    config.bypass_auth = false
  end
end

if Rails.env.test?
  RpiAuth.configure do |config|
    config.auth_url = 'http://fakeauth.com'
    config.auth_client_id = 'clientid'
    config.auth_client_secret = 'clientsecret'
    config.host_url = 'https://fakepi.com'
    config.identity_url = 'https://my.fakepi.com'
    config.user_model = 'User'
    config.success_redirect = '/'
    config.bypass_auth = true
  end
end
