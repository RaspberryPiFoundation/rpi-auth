# frozen_string_literal: true

module RpiAuth
  module Controllers
    module CurrentUser
      extend ActiveSupport::Concern

      included do
        helper_method :current_user if respond_to?(:helper_method)
      end

      # Make sure our memoized user is cleared out on reset
      def reset_session
        @current_user = nil
        super
      end

      def current_user
        return nil unless session[:current_user]
        return @current_user if @current_user

        @current_user = RpiAuth.user_model.new(session[:current_user])
      end

      def current_user=(user)
        session[:current_user] = user.serializable_hash

        @current_user = user
      end
    end
  end
end
