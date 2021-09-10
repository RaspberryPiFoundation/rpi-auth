module RpiAuth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Model
        include ActiveModel::Serialization
      end

      PROFILE_KEYS = %w[
        country_code
        email
        name
        nickname
        picture
        profile
        roles
      ].freeze
      attr_accessor :id, *PROFILE_KEYS

      # Allow serialization
      def attributes
        (['id'] + PROFILE_KEYS).index_with { |_k| nil }
      end

      class_methods do
        def from_omniauth(auth)
          return nil unless auth

          args = auth.info.to_h.slice(*PROFILE_KEYS)
          args['id'] = auth.uid

          new(args)
        end
      end
    end
  end
end
