# frozen_string_literal: true

module RpiAuth
  module Models
    module AccountTypes
      STUDENT_PREFIX = 'student:'

      extend ActiveSupport::Concern

      include Authenticatable

      def student_account?
        user_id =~ /^#{STUDENT_PREFIX}/o
      end
    end
  end
end
