# frozen_string_literal: true

module RpiAuth
  class AuthController < ApplicationController
    # rubocop:disable Metrics/AbcSize
    def callback
      # Prevent session fixation. If the session has been initialized before
      # this, and we need to keep the data, then we should copy values over.
      reset_session

      auth = request.env['omniauth.auth']
      user = RpiAuth.user_model.from_omniauth(auth)
      session[:current_user] = user

      return redirect_to RpiAuth.configuration.success_redirect if RpiAuth.configuration.success_redirect

      if request.env.key?('omniauth.origin') && request.env['omniauth.origin'].present?
        return redirect_to(request.env['omniauth.origin'], allow_other_host: false)
      end

      redirect_to '/'
      # rubocop:enable Metrics/AbcSize
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
