# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RpiAuth::OauthClient do
  include ActiveSupport::Testing::TimeHelpers

  describe '#refresh_credentials' do
    subject(:refresh_credentials) { oauth_client.refresh_credentials(**credentials) }

    let(:oauth_client) { described_class.new }
    let(:credentials) { { access_token: 'foo', refresh_token: 'bar' } }
    let(:refresh_body) { { token: 'baz', refresh_token: 'quux', expires_in: rand(300..600) } }

    before do
      RpiAuth.configure do |config|
        config.bypass_auth = bypass_auth
        config.auth_url = 'https://auth.com:123/'
      end

      freeze_time
    end

    after do
      unfreeze_time
    end

    context 'when RpiAuth.configuration.bypass is not set' do
      let(:bypass_auth) { false }

      before do
        stub_request(:post, RpiAuth.configuration.token_endpoint)
          .with(body: { grant_type: 'refresh_token', refresh_token: credentials[:refresh_token] })
          .to_return(status: 200, body: refresh_body.to_json, headers: { content_type: 'application/json' })
      end

      it do
        expect(refresh_credentials).to eq({ access_token: refresh_body[:token],
                                            refresh_token: refresh_body[:refresh_token],
                                            expires_at: Time.now.to_i + refresh_body[:expires_in] })
      end
    end

    context 'when RpiAuth.configuration.bypass is set' do
      let(:bypass_auth) { true }

      it { expect(refresh_credentials).to eq credentials.merge(expires_at: 1.hour.from_now.to_i) }
    end
  end
end
