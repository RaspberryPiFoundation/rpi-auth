# frozen_string_literal: true

module RpiAuth
  module AuthenticationHelper
    def current_user
      return @current_user if defined? @current_user
      return nil unless session[:current_user]

      @current_user = RpiAuth.user_model.new(session[:current_user])
    end
  end
end
