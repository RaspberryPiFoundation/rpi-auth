# frozen_string_literal: true

require 'rpi_auth/controllers/current_user'

module RpiAuth
  class ApplicationController < ActionController::Base
    include RpiAuth::Controllers::CurrentUser
  end
end
