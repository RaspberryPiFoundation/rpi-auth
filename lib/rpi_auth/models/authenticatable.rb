# frozen_string_literal: true

require 'json'
require 'base64'

module RpiAuth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      PROFILE_KEYS = %w[
        country
        country_code
        email
        email_verified
        name
        nickname
        picture
        postcode
        profile
        roles
        sid
      ].freeze

      included do
        include ActiveModel::Model
        include ActiveModel::Serialization

        attr_accessor :user_id, *PROFILE_KEYS
      end

      def attribute_keys
        %w[user_id] + PROFILE_KEYS
      end

      # Allow serialization
      def attributes
        attribute_keys.map(&:to_s).index_with { |_k| nil }
      end

      class_methods do
        def from_omniauth(auth)
          return nil unless auth

          args = auth.extra.raw_info.to_h.slice(*PROFILE_KEYS)
          args['user_id'] = auth.uid

          # Extract sid from id_token if not already in raw_info
          # sid may be nil if not available (backward compatible with old sessions)
          args['sid'] ||= extract_sid(auth)

          new(args)
        end

        private

        def extract_sid(auth)
          # Decode sid from id_token (raw_info is already checked via slice above)
          id_token = auth.extra&.id_token || auth.credentials&.id_token
          return unless id_token

          decode_sid_from_token(id_token)
        end

        def decode_sid_from_token(id_token)
          parts = id_token.split('.')
          return unless parts.length == 3

          payload = parts[1]
          payload += '=' * (4 - (payload.length % 4)) if payload.length % 4 != 0
          decoded_payload = Base64.urlsafe_decode64(payload)
          claims = JSON.parse(decoded_payload)

          claims['sid']
        rescue StandardError => e
          Rails.logger.warn("Failed to extract sid from id_token: #{e.message}")
          nil
        end
      end
    end
  end
end
