# frozen_string_literal: true

require 'rpi_auth/oauth_client'

module RpiAuth
  module Models
    module WithTokens
      extend ActiveSupport::Concern

      include Authenticatable

      included do
        attr_accessor :access_token, :expires_at, :refresh_token
      end

      def attribute_keys
        super + %w[access_token expires_at refresh_token user_id]
      end

      def refresh_credentials!
        oauth_client = OauthClient.new
        credentials = oauth_client.refresh_credentials(access_token:, refresh_token:)

        assign_attributes(**credentials)
      end

      class_methods do
        def from_omniauth(auth)
          user = super
          return unless user

          if auth.credentials
            user.access_token = auth.credentials.token
            user.refresh_token = auth.credentials.refresh_token
            user.expires_at = Time.now.to_i + auth.credentials.expires_in
          end

          user
        end
      end
    end
  end
end
