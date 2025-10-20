# frozen_string_literal: true

require 'rpi_auth/controllers/current_user'

module RpiAuth
  class AuthController < ActionController::Base
    include RpiAuth::Controllers::CurrentUser

    protect_from_forgery with: :null_session

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
      self.current_user = RpiAuth.user_model.from_omniauth(auth)

      run_login_success_callback

      redirect_to ensure_relative_url(login_redirect_path)
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

    def run_login_success_callback
      return unless RpiAuth.configuration.on_login_success.is_a?(Proc)

      begin
        instance_exec(&RpiAuth.configuration.on_login_success)
      rescue StandardError => e
        Rails.logger.warn("Caught #{e} while processing on_login_success proc.")
      end
    end

    def login_redirect_path
      unless RpiAuth.configuration.success_redirect.is_a?(Proc)
        return RpiAuth.configuration.success_redirect || request.env['omniauth.origin']
      end

      begin
        instance_exec(&RpiAuth.configuration.success_redirect)&.to_s
      rescue StandardError => e
        Rails.logger.warn("Caught #{e} while processing success_redirect proc.")
        '/'
      end
    end

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
