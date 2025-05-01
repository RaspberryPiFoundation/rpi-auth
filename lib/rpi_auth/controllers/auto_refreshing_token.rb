# frozen_string_literal: true

require 'oauth2/error'

module RpiAuth
  module Controllers
    module AutoRefreshingToken
      extend ActiveSupport::Concern

      include CurrentUser

      included do
        before_action :refresh_credentials_if_needed if respond_to?(:before_action)
      end

      private

      def refresh_credentials_if_needed
        return unless current_user

        return if Time.now.to_i < current_user.expires_at

        current_user.refresh_credentials!
        self.current_user = current_user
      rescue OAuth2::Error, ArgumentError
        reset_session
      end
    end
  end
end
