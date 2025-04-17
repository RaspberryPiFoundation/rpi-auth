require 'rpi_auth/controllers/current_user'
require 'rpi_auth/controllers/auto_refreshing_token'

class ApplicationController < ActionController::Base
  include RpiAuth::Controllers::CurrentUser
  include RpiAuth::Controllers::AutoRefreshingToken
end
