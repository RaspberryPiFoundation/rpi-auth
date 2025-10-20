class User
  include RpiAuth::Models::Authenticatable
  include RpiAuth::Models::WithTokens
end
