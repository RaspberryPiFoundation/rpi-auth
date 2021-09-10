require 'spec_helper'

RSpec.describe 'Authentication', type: :request do
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
  let(:identity_url) { 'https://my.fakepi.com' }
  let(:host_url) { 'https://fakepi.com' }

  before do

  end

  # let(:env) do
  #   {
  #     BYPASS_OAUTH: bypass_oauth,
  #     HOST_URL: host_url,
  #     IDENTITY_URL: identity_url
  #   }
  # end

  # around do |example|
  #   ClimateControl.modify(env) do
  #     example.run
  #   end
  # end

  # describe 'GET /login' do
  #   it 'redirects to /auth/rpi' do
  #     get '/login'
  #     expect(response).to redirect_to('/auth/rpi')
  #   end
  # end

  describe 'GET /rpi_auth/logout' do
    before do
      RpiAuth.configuration.bypass_auth = false
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

    context 'when BYPASS_OAUTH is set' do
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
                                 uid: user[:id],
                                 info: user.except(:id))
      end

      it 'sets the user in the session and redirects to root path' do
        post '/auth/rpi'
        expect(response).to redirect_to('/rpi_auth/auth/callback')
        follow_redirect!

        expect(response).to redirect_to('/')
        expect(session[:current_user].id).to eq user[:id]
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
