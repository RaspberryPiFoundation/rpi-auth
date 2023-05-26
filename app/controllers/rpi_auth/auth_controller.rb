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
                  ensure_relative_url(request.env['omniauth.origin'])
    end

    def destroy
      reset_session

      # Any redirect must be within our app, so it should start with a slash.
      return_to = ensure_relative_url(params[:returnTo])

      return redirect_to return_to if RpiAuth.configuration.bypass_auth == true

      redirect_to "#{RpiAuth.configuration.identity_url}/logout?returnTo=#{RpiAuth.configuration.host_url}#{return_to}",
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

    private

    def ensure_relative_url(url)
      url = URI.parse(url)

      # Bail out early if the URL doesn't look local. This condition is taken
      # from ActionController::Redirecting#_url_host_allowed? in Rails 7.0
      raise ArgumentError unless url.host == request.host || (url.host.nil? && url.to_s.start_with?('/'))

      # This is a bit of an odd way to do things, but it means that this method
      # works with both URI::Generic and URI::HTTP
      relative_url = [url.path, url.query].compact.join('?')
      [relative_url, url.fragment].compact.join('#')
    rescue ArgumentError, URI::Error
      '/'
    end
  end
end
