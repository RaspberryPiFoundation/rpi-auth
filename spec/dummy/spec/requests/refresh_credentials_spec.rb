# frozen_string_literal: true

require 'spec_helper'

require 'oauth2'

RSpec.describe 'Refreshing the auth token', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  subject(:request) { get root_path }

  let(:logged_in_text) { 'Log out' }
  let(:stub_oauth_client) { instance_double(RpiAuth::OauthClient) }

  before do
    freeze_time
    allow(RpiAuth::OauthClient).to receive(:new).and_return(stub_oauth_client)
    allow(stub_oauth_client).to receive(:refresh_credentials).with(any_args)
    RpiAuth.configuration.user_model = 'User'
  end

  after do
    unfreeze_time
  end

  shared_examples 'there is no attempt to renew the token' do
    it 'calls refresh_credentials on the oauth client' do
      request
      expect(stub_oauth_client).not_to have_received(:refresh_credentials)
    end
  end

  shared_examples 'there is an attempt to renew the token' do
    it 'does not call refresh_credentials on the oauth client' do
      request
      expect(stub_oauth_client).to have_received(:refresh_credentials)
    end
  end

  shared_examples 'the user is logged in' do
    it do
      request
      expect(response.body).to include(logged_in_text)
    end
  end

  shared_examples 'the user is logged out' do
    it do
      request
      expect(response.body).not_to include(logged_in_text)
    end
  end

  context 'when not logged in' do
    it_behaves_like 'the user is logged out'
    it_behaves_like 'there is no attempt to renew the token'
  end

  context 'when logged in' do
    let(:user) { User.new(expires_at:) }

    before do
      log_in(user:)
    end

    context 'when the access token is valid for at least another 60 seconds' do
      let(:expires_at) { 60.seconds.from_now }

      it_behaves_like 'the user is logged in'
      it_behaves_like 'there is no attempt to renew the token'
    end

    context 'when the access token expires in the next 60 seconds' do
      let(:expires_at) { 59.seconds.from_now }

      before do
        allow(stub_oauth_client).to receive(:refresh_credentials).with(any_args).and_return({ access_token: 'foo',
                                                                                              refresh_token: 'bar',
                                                                                              expires_at: 10.minutes.from_now })
      end

      it_behaves_like 'the user is logged in'
      it_behaves_like 'there is an attempt to renew the token'

      context 'when an OAuth error is raised' do
        let(:oauth_error) { OAuth2::Error.new('blargh') }
        before do
          allow(stub_oauth_client).to receive(:refresh_credentials).with(any_args).and_raise(oauth_error)
        end

        it_behaves_like 'the user is logged out'
        it_behaves_like 'there is an attempt to renew the token'

        context 'when an on_token_refresh_error callback is provided' do
          let(:on_token_refresh_error_callback) { spy(:on_token_refresh_error) }
          before do
            RpiAuth.configuration.on_token_refresh_error_callback = on_token_refresh_error_callback
          end

          it_behaves_like 'the user is logged out'
          it_behaves_like 'there is an attempt to renew the token'

          it 'calls the callback' do
            request
            expect(on_token_refresh_error_callback).to have_received(:call).with(oauth_error)
          end
        end
      end
    end
  end
end
