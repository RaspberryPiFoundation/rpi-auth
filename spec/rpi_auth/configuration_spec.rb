# frozen_string_literal: true

RSpec.describe RpiAuth::Configuration do
  subject(:configuration) { described_class.new }

  let(:auth_url) { 'https://auth.com:123/' }
  let(:auth_token_url) { 'https://internal.auth.com:456' }

  it 'sets a default value for client_auth_method' do
    expect(configuration.client_auth_method).to eq :basic
  end

  it 'sets a default value for response_type' do
    expect(configuration.response_type).to eq :code
  end

  it 'sets bypass_auth to false by default' do
    expect(configuration.bypass_auth).to be_falsey
  end

  describe '#enable_auth_bypass' do
    context 'when bypass_auth is true' do
      before do
        configuration.bypass_auth = true
      end

      it 'enables OmniAuth test mode' do
        expect { configuration.enable_auth_bypass }.to change { OmniAuth.config.test_mode }.from(false).to(true)
      end
    end

    context 'when bypass_auth is false' do
      before do
        configuration.bypass_auth = false
      end

      it 'does not enable OmniAuth test mode' do
        expect { configuration.enable_auth_bypass }.not_to change { OmniAuth.config.test_mode }.from(false)
      end
    end
  end

  describe 'disable_auth_bypass' do
    before do
      configuration.bypass_auth = true
      configuration.enable_auth_bypass
    end

    it 'disables OmniAuth test mode' do
      expect { configuration.disable_auth_bypass }.to change { OmniAuth.config.test_mode }.from(true).to(false)
    end
  end

  describe '#authorization_endpoint' do
    it 'raises an exception if auth_url is not set' do
      expect { configuration.authorization_endpoint }.to raise_exception(ArgumentError)
    end

    context 'when auth_url is set' do
      let(:expected_url) { auth_url }

      before { configuration.auth_url = auth_url }

      it 'sets the authorization_endpoint correctly' do
        expect(configuration.authorization_endpoint).to eq URI.parse(auth_url).merge('/oauth2/auth')
      end
    end
  end

  shared_examples 'sets up the token url defaults' do
    it 'sets the issuer' do
      expect(configuration.issuer).to eq URI.parse(expected_url).merge('/').to_s
    end

    it 'sets the token_endpoint' do
      expect(configuration.token_endpoint).to eq URI.parse(expected_url).merge('/oauth2/token')
    end

    it 'sets the jwks uri' do
      expect(configuration.jwks_uri).to eq URI.parse(expected_url).merge('/.well-known/jwks.json')
    end
  end

  describe '#token_endpoint' do
    it 'raises an exception if auth_url is not set' do
      expect { configuration.token_endpoint }.to raise_exception(ArgumentError)
    end

    context 'when auth_url is set' do
      let(:expected_url) { auth_url }

      before { configuration.auth_url = auth_url }

      it_behaves_like 'sets up the token url defaults'

      context 'when auth_token_url is set' do
        let(:expected_url) { auth_token_url }

        before { configuration.auth_token_url = auth_token_url }

        it_behaves_like 'sets up the token url defaults'
      end
    end

    context 'when auth_token_url is set' do
      let(:expected_url) { auth_token_url }

      before { configuration.auth_token_url = auth_token_url }

      it_behaves_like 'sets up the token url defaults'
    end
  end
end
