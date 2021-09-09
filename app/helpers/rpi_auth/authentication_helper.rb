module RpiAuth
  module AuthenticationHelper
    def current_user
      return @current_user if @current_user
      return nil unless session[:current_user]

      @current_user = RpiAuth.configuration.user_model.new(session[:current_user])
    end
  end
end
