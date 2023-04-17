class ApplicationController < ActionController::Base
  include RpiAuth::Controllers::CurrentUser
end
