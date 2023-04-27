# frozen_string_literal: true

require 'rpi_auth/controllers/current_user'


module RpiAuth
  class AuthController < ActionController::Base
    include RpiAuth::Controllers::CurrentUser

    protect_from_forgery with: :null_session

    def callback
      # Prevent session fixation. If the session has been initialized before
      # this, and we need to keep the data, then we should copy values over.
      reset_session

      auth = request.env['omniauth.auth']
      self.current_user = RpiAuth.user_model.from_omniauth(auth)

      redirect_to RpiAuth.configuration.success_redirect.presence ||
                  request.env.fetch('omniauth.origin', nil).presence ||
                  '/'
    end

    def destroy
      reset_session

      # Prevent redirect loops etc.
      if RpiAuth.configuration.bypass_auth == true
        redirect_to '/'
        return
      end

      redirect_to "#{RpiAuth.configuration.identity_url}/logout?returnTo=#{RpiAuth.configuration.host_url}",
                  allow_other_host: true
    end

    def failure
      flash[:alert] = if request.env['omniauth.error.type'] == :not_verified
                        'Login error - account not verified'
                      else
                        'Login error'
                      end
      redirect_to '/'
    end
  end
end
