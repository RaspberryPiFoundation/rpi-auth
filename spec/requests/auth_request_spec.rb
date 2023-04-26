# frozen_string_literal: true

require 'spec_helper'

class DummyUser
  extend RpiAuth::Models::Authenticatable
end

RSpec.describe 'Authentication' do
  let(:user) do
    {
      email: 'person@example.com',
      id: '3ed9b57a-1eb9-42e1-ae54-9a11c930f035',
      country_code: 'GB',
      name: 'Sylvester McBean',
      nickname: 'Sylvie',
      picture: 'https://placecage.com/100/100',
      profile: 'https://my.raspberry.pi/profile/edit'
    }
  end
  let(:bypass_oauth) { '' }
  let(:identity_url) { 'https://my.example.com' }
  let(:host_url) { 'https://example.com' }

  before do
    RpiAuth.configuration.user_model = 'DummyUser'
  end

  after do
    # Reset value or it affects other tests :(
    RpiAuth.configuration.user_model = 'User'
  end

  describe 'GET /rpi_auth/logout' do
    before do
      RpiAuth.configuration.bypass_auth = false
      RpiAuth.configuration.log_out_url = nil
      sign_in(user)
    end

    it 'clears the current session and redirects to profile' do
      expect(session['current_user']).not_to be_nil
      previous_id = session.id

      get '/rpi_auth/logout'

      expect(response).to redirect_to("#{identity_url}/logout?returnTo=#{host_url}")
      expect(session.id).not_to eq previous_id
      expect(session['current_user']).to be_nil
    end

    it 'clears the current session and redirects to a specified log out endpoint' do
      RpiAuth.configuration.log_out_url = 'https://auth.example.com/oauth2/sessions/logout'
      expect(session['current_user']).not_to be_nil
      previous_id = session.id

      get '/rpi_auth/logout'

      expect(response).to redirect_to('https://auth.example.com/oauth2/sessions/logout')
      expect(session.id).not_to eq previous_id
      expect(session['current_user']).to be_nil
    end

    context 'when bypass_auth is set' do
      before do
        RpiAuth.configuration.bypass_auth = true
      end

      it 'clears the current session and redirects to root' do
        expect(session['current_user']).not_to be_nil
        previous_id = session.id

        get '/rpi_auth/logout'

        expect(response).to redirect_to('/')
        expect(session.id).not_to eq previous_id
        expect(session['current_user']).to be_nil
      end
    end
  end

  describe 'POST /auth/rpi' do
    before do
      OmniAuth.config.mock_auth[:rpi] = nil
    end

    describe 'On failed authentication' do
      let(:error) { :invalid_credentials }

      before do
        OmniAuth.config.mock_auth[:rpi] = error
      end

      it 'flashes an error message and leaves current_user unset' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(response).to redirect_to('/')
        expect(session['current_user']).to be_nil
        expect(flash['alert']).to eq 'Login error'
      end

      context 'when the failure is because the account is unverified' do
        let(:error) { :not_verified }

        it 'flashes an error message and leaves current_user unset' do
          post '/auth/rpi'
          expect(response).to redirect_to('/rpi_auth/auth/callback')
          follow_redirect!

          expect(response).to redirect_to('/')
          expect(session['current_user']).to be_nil
          expect(flash['alert']).to eq 'Login error - account not verified'
        end
      end
    end

    describe 'On successful authentication' do
      before do
        OmniAuth.config.add_mock(:rpi,
                                 uid: user[:user_id],
                                 extra: { raw_info: user.except(:user_id) })
      end

      it 'sets the user in the session and redirects to root path' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(response).to redirect_to('/')
        expect(session[:current_user].user_id).to eq user[:user_id]
        expect(session[:current_user].email).to eq user[:email]
      end

      it 'resets the session ID on login' do
        post '/auth/rpi'
        previous_id = session.id

        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(session.id).not_to eq previous_id
      end
    end
  end
end
