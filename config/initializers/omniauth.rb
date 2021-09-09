# OmniAuth.config.logger = Rails.logger
# puts '*'*50
# puts 'bypass?'
# puts ENV['BYPASS_OAUTH'].present?
# puts 'Env vars:'
# puts "AUTH_CLIENT_ID: #{ENV['AUTH_CLIENT_ID'] }"
# puts "AUTH_CLIENT_SECRET: #{ENV['AUTH_CLIENT_SECRET']}"
# puts "AUTH_URL: #{ENV['AUTH_URL']}"
# puts '*'*50
# # puts RpiAuth.configuration
# # binding.pry
#
# if ENV['BYPASS_OAUTH'].present?
#   using RpiAuthBypass
#   OmniAuth.config.add_rpi_mock(
#     uid: 'b6301f34-b970-4d4f-8314-f877bad8b150',
#     info: {
#       email: 'web@raspberrypi.org',
#       name: 'Digital Products Team',
#       nickname: 'DP',
#       image: 'https://static.raspberrypi.org/files/accounts/default-avatar.jpg'
#     },
#     extra: {
#       raw_info: {
#         name: 'Digital Products Team',
#         nickname: 'DP',
#         email: 'web@raspberrypi.org',
#         country: 'United Kingdom',
#         country_code: 'GB',
#         postcode: 'SW1A 1AA',
#         picture: 'https://static.raspberrypi.org/files/accounts/default-avatar.jpg',
#         profile: 'https://my.raspberrypi.org/not/a/real/path'
#       }
#     }
#   )
#   OmniAuth.config.enable_rpi_auth_bypass
# end
#
# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider(
#     OmniAuth::Strategies::Rpi, ENV['AUTH_CLIENT_ID'], ENV['AUTH_CLIENT_SECRET'],
#     scope: 'openid email profile force-consent',
#     callback_path: '/auth/callback',
#     client_options: {
#       site: ENV['AUTH_URL'],
#       authorize_url: "#{ENV['AUTH_URL']}/oauth2/auth",
#       token_url: "#{ENV['AUTH_URL']}/oauth2/token"
#     },
#     authorize_params: {
#       brand: 'd2l'
#     }
#   )
#
#   OmniAuth.config.on_failure = RpiAuth::AuthController.action(:failure)
# end
