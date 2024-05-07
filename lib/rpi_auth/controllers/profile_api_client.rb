# frozen_string_literal: true

module RpiAuth
  module Controllers
    module ProfileApiClient
      extend ActiveSupport::Concern

      included do
        helper_method :profile_api_client
      end

      def profile_api_client
        return @profile_api_client if @profile_api_client
        return nil unless session[:profile_api_client_config]

        puts '******************'
        puts 'Creating new client'
        puts '******************'

        RpiAuth.configuration.profile_api_class.configure do |config|
          config.scheme = RpiAuth.configuration.profile_api_scheme
          config.host = RpiAuth.configuration.profile_api_host
          # Configure a proc to get access tokens in lieu of the static access_token configuration
          config.access_token_getter = -> {
            refresh_access_token if access_token_expired?

            profile_api_client_config['access_token']
          } 
        end

        @profile_api_client = RpiAuth.configuration.profile_api_class::DefaultApi.new
        @profile_api_client
      end

      def profile_api_client_config=(config)
        session[:profile_api_client_config] = config.transform_keys(&:to_s)
      end

      def profile_api_client_config
        return nil unless session[:profile_api_client_config]

        session[:profile_api_client_config]
      end

      def refresh_access_token
        request_time = Time.now.to_i
        req = Net::HTTP::Post.new(RpiAuth.configuration.token_endpoint)
        req.set_form_data(
          grant_type: 'refresh_token',
          refresh_token: profile_api_client_config['refresh_token'],
        )
        req.basic_auth(
          RpiAuth.configuration.auth_client_id,
          RpiAuth.configuration.auth_client_secret,
        )
        res = Net::HTTP.start(RpiAuth.configuration.token_endpoint.hostname, RpiAuth.configuration.token_endpoint.port) { |http| http.request(req) }
        json = JSON.parse(res.body)
        profile_api_client_config['access_token'] = json['access_token']
        profile_api_client_config['expires_at'] = request_time + json['expires_in']
        profile_api_client_config['refresh_token'] = json['refresh_token']
      end

      def access_token_expired?
        return true if profile_api_client_config['expires_at'].nil?

        Time.now.to_i > profile_api_client_config['expires_at']
      end
    end
  end
end
