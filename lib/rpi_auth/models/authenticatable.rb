# frozen_string_literal: true

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
      ].freeze

      included do
        include ActiveModel::Model
        include ActiveModel::Serialization

        attr_accessor :user_id, *PROFILE_KEYS
      end

      # Allow serialization
      def attributes
        (['user_id'] + PROFILE_KEYS).index_with { |_k| nil }
      end

      class_methods do
        def from_omniauth(auth)
          return nil unless auth

          args = auth.extra.raw_info.to_h.slice(*PROFILE_KEYS)
          args['user_id'] = auth.uid

          new(args)
        end
      end
    end
  end
end
