# frozen_string_literal: true

module RpiAuth
  class AuthController < ApplicationController
    protect_from_forgery with: :null_session

    # rubocop:disable Metrics/AbcSize
    def callback
      # Prevent session fixation. If the session has been initialized before
      # this, and certain data needs to be persisted, then the client should
      # pass the keys via config.session_keys_to_persist
      old_session = session.to_hash

      reset_session

      keys_to_persist = RpiAuth.configuration.session_keys_to_persist

      unless keys_to_persist.nil? || keys_to_persist.empty?
        keys_to_persist.split.each do |key|
          session[key] = old_session[key]
        end
      end

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
