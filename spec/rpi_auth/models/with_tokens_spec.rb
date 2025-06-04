# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RpiAuth::Models::WithTokens, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  subject(:user) { user_class.new }

  let(:user_class) do
    Class.new(User) do
      include RpiAuth::Models::Authenticatable
      include RpiAuth::Models::WithTokens
    end
  end

  it { is_expected.to respond_to(:access_token) }
  it { is_expected.to respond_to(:refresh_token) }
  it { is_expected.to respond_to(:expires_at) }

  describe '#refresh_credentials!' do
    subject(:refresh_credentials) { user.refresh_credentials! }

    let(:stub_oauth_client) { instance_double(RpiAuth::OauthClient) }
    let(:new_tokens) { { access_token: 'foo', refresh_token: 'bar', expires_at: 1.hour.from_now.utc } }

    before do
      allow(RpiAuth::OauthClient).to receive(:new).and_return(stub_oauth_client)
      allow(stub_oauth_client).to receive(:refresh_credentials).with(access_token: user.access_token, refresh_token: user.refresh_token).and_return(new_tokens)
    end

    it { expect { refresh_credentials }.to change(user, :access_token).from(user.access_token).to(new_tokens[:access_token]) }
    it { expect { refresh_credentials }.to change(user, :refresh_token).from(user.refresh_token).to(new_tokens[:refresh_token]) }
    it { expect { refresh_credentials }.to change(user, :expires_at).from(user.expires_at).to(new_tokens[:expires_at]) }
  end

  describe '#from_omniauth' do
    subject(:user) { user_class.from_omniauth(auth) }

    let(:omniauth_user) { user_class.new }
    let(:info) { omniauth_user.serializable_hash }
    let(:credentials) { { token: SecureRandom.base64(12), refresh_token: SecureRandom.base64(12), expires_in: rand(60..240) } }

    let(:auth) do
      OmniAuth::AuthHash.new(
        {
          provider: 'rpi',
          uid: omniauth_user.user_id,
          credentials:,
          extra: {
            raw_info: info
          }
        }
      )
    end

    it { is_expected.to be_a user_class }

    it 'sets the access_token' do
      expect(user.access_token).to eq credentials[:token]
    end

    it 'sets the refresh_token' do
      expect(user.refresh_token).to eq credentials[:refresh_token]
    end

    context 'when no credentials are returned' do
      let(:credentials) { nil }

      it 'sets the access_token to be nil' do
        expect(user.access_token).to be_nil
      end
    end

    it 'sets the expires_at time correctly' do
      freeze_time do
        expect(user.expires_at).to eq credentials[:expires_in].seconds.from_now.to_i
      end
    end

    context 'with unusual keys in info' do
      let(:info) { { foo: :bar, flibble: :woo } }

      it { is_expected.to be_a user_class }
    end

    context 'with no info' do
      let(:info) { nil }

      it { is_expected.to be_a user_class }
    end

    context 'with no auth set' do
      let(:auth) { nil }

      it { is_expected.to be_nil }
    end
  end
end
