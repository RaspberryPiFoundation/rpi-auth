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
        return if current_user.blank? || current_user.expires_at.blank?

        return if Time.now.to_i + REFRESH_WINDOW_IN_SECONDS <= current_user.expires_at

        # This raises an OAuth2::Error on failure, which is rescued by the
        # handle_oauth2_error method.
        current_user.refresh_credentials!
        self.current_user = current_user
      rescue OAuth2::Error
        # Catching here allows the controller to continue on from where it left
        # off.
        reset_session
      end
    end
  end
end
