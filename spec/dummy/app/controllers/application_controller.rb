require 'rpi_auth/controllers/current_user'
class ApplicationController < ActionController::Base
  include RpiAuth::Controllers::CurrentUser
end
