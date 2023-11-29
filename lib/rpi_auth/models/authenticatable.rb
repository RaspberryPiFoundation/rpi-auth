# frozen_string_literal: true

module RpiAuth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Model
        include ActiveModel::Serialization
      end

      PROFILE_KEYS = %w[
        country
        country_code
        email
        name
        nickname
        picture
        profile
        roles
      ].freeze
      attr_accessor :user_id, *PROFILE_KEYS

      # Allow serialization
      def attributes
        (['user_id'] + PROFILE_KEYS).index_with { |_k| nil }
      end

      def from_omniauth(auth)
        return nil unless auth

        args = auth.extra.raw_info.to_h.slice(*PROFILE_KEYS)
        args['user_id'] = auth.uid

        new(args)
      end
    end
  end
end
