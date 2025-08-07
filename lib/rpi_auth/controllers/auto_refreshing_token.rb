# frozen_string_literal: true

require 'oauth2'

module RpiAuth
  module Controllers
    module AutoRefreshingToken
      REFRESH_WINDOW_IN_SECONDS = 60

      extend ActiveSupport::Concern

      include CurrentUser

      included do
        before_action :refresh_credentials_if_needed if respond_to?(:before_action)
      end

      private

      def refresh_credentials_if_needed
        return unless current_user

        return if Time.now.to_i + REFRESH_WINDOW_IN_SECONDS <= current_user.expires_at

        current_user.refresh_credentials!
        self.current_user = current_user
      rescue OAuth2::Error, ArgumentError => e
        on_token_refresh_error(e)
      end

      def on_token_refresh_error(error)
        reset_session
        if on_token_refresh_error_callback.respond_to?(:call)
          on_token_refresh_error_callback.call(error)
        end
      end

      def on_token_refresh_error_callback
        RpiAuth.configuration.on_token_refresh_error_callback
      end
    end
  end
end
