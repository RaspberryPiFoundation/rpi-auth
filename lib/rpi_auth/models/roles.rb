# frozen_string_literal: true

module RpiAuth
  module Models
    module Roles
      extend ActiveSupport::Concern

      include Authenticatable

      def parsed_roles
        roles&.split(',')&.map(&:strip) || []
      end
    end
  end
end
