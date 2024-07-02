# frozen_string_literal: true

require 'rpi_auth/controllers/current_user'

module RpiAuth
  class TestController < ActionController::Base
    include RpiAuth::Controllers::CurrentUser
    include Rails.application.routes.url_helpers

    layout false

    def show
      head :not_found if Rails.env.production?

      render locals: { login_params: login_params, logout_params: logout_params }
    end

    def login_params
      params.permit(:returnTo)
    end

    alias logout_params login_params
  end
end
