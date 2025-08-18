# frozen_string_literal: true

module RpiAuth
  module Models
    module AccountTypes
      STUDENT_PREFIX = 'student:'

      extend ActiveSupport::Concern

      include Authenticatable

      def student_account?
        return false if user_id.blank?

        user_id.start_with?(STUDENT_PREFIX)
      end
    end
  end
end
