# frozen_string_literal: true

require 'spec_helper'

require 'oauth2'

RSpec.describe 'Refreshing the auth token', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  subject(:request) { get root_path }

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
      expect(response.body).to include('Logged in as')
    end
  end

  shared_examples 'the user is logged out' do
    it do
      request
      expect(response.body).to include('Logged out')
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
        before do
          allow(stub_oauth_client).to receive(:refresh_credentials).with(any_args).and_raise(OAuth2::Error.new('blargh'))
        end

        it_behaves_like 'the user is logged out'
        it_behaves_like 'there is an attempt to renew the token'
      end
    end
  end
end
