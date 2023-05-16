# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Authentication' do
  let(:user) do
    User.new(
      email: 'person@example.com',
      user_id: '3ed9b57a-1eb9-42e1-ae54-9a11c930f035',
      country_code: 'GB',
      name: 'Sylvester McBean',
      nickname: 'Sylvie',
      picture: 'https://placecage.com/100/100',
      profile: 'https://my.raspberry.pi/profile/edit'
    )
  end

  let(:bypass_auth) { false }
  let(:identity_url) { 'https://my.example.com' }
  let(:host_url) { 'https://example.com' }

  before do
    RpiAuth.configuration.user_model = 'User'
    RpiAuth.configuration.identity_url = identity_url
    RpiAuth.configuration.host_url = host_url
    RpiAuth.configuration.bypass_auth = bypass_auth
    # This would normally be in the initializer, but because we're toggling the
    # option on or off, we need to explicitly call it here.
    RpiAuth.configuration.enable_auth_bypass
    OmniAuth.config.test_mode = true
  end

  describe 'GET /rpi_auth/logout' do
    it 'clears the current session and redirects to profile' do
      sign_in(user)
      expect(session['current_user']).not_to be_nil
      previous_id = session.id

      get '/rpi_auth/logout'

      expect(response).to redirect_to("#{identity_url}/logout?returnTo=#{host_url}")
      expect(session.id).not_to eq previous_id
      expect(session['current_user']).to be_nil
    end

    context 'when bypass_auth is set' do
      let(:bypass_auth) { true }

      it 'clears the current session and redirects to root' do
        post '/auth/rpi'
        follow_redirect!

        expect(session['current_user']['user_id']).to eq RpiAuthBypass::DEFAULT_UID
        previous_id = session.id

        get '/rpi_auth/logout'

        expect(response).to redirect_to('/')
        expect(session.id).not_to eq previous_id
        expect(session['current_user']).to be_nil
      end
    end
  end

  describe 'POST /auth/rpi' do
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

    context 'when bypass_auth is set' do
      let(:bypass_auth) { true }

      it 'clears the current session and redirects to root' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(response).to redirect_to('/')
        follow_redirect!

        expect(session['current_user']['user_id']).to eq RpiAuthBypass::DEFAULT_UID
      end
    end

    describe 'On successful authentication' do
      before do
        stub_auth_for(user)
      end

      it 'sets the user in the session and redirects to root path' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(session[:current_user]['user_id']).to eq user.user_id
        expect(session[:current_user]['email']).to eq user.email
      end

      it 'redirects to root path' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(response).to redirect_to('/')
      end

      it 'resets the session ID on login' do
        post '/auth/rpi'
        previous_id = session.id

        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(session.id).not_to eq previous_id
      end

      context 'when having visited a page first' do
        it 'redirects back to the original page' do
          post '/auth/rpi', headers: { Referer: 'http://www.example.com/foo' }
          expect(response).to redirect_to('/rpi_auth/auth/callback')
          follow_redirect!

          expect(response).to redirect_to('/foo')
        end
      end

      context 'when returnTo param is set' do
        it 'redirects back to the original page' do
          post '/auth/rpi', params: { returnTo: 'http://www.example.com/bar' }
          expect(response).to redirect_to('/rpi_auth/auth/callback')
          follow_redirect!

          expect(response).to redirect_to('/bar')
        end
      end

      context 'when success_redirect is set in config' do
        before do
          RpiAuth.configuration.success_redirect = 'http://www.example.com/success'
        end

        it 'redirects back to the success page' do
          post '/auth/rpi'
          expect(response).to redirect_to('/rpi_auth/auth/callback')
          follow_redirect!

          expect(response).to redirect_to('/success')
        end
      end
    end
  end
end
