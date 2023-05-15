# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RpiAuthBypass do
  using described_class

  around do |example|
    # Alter logger to hide log messages.
    level = OmniAuth.config.logger.level
    OmniAuth.config.logger.level = Logger::WARN

    example.run

    OmniAuth.config.disable_rpi_auth_bypass
    OmniAuth.config.logger.level = level
  end

  describe 'OmniAuth::Configuration#enable_rpi_auth_bypass' do
    subject(:call) { OmniAuth.config.enable_rpi_auth_bypass }

    it 'sets test_mode to true' do
      expect { call }.to change { OmniAuth.config.test_mode }.from(false).to(true)
    end

    it 'adds the rpi mock' do
      expect { call }.to change { OmniAuth.config.mock_auth[:rpi] }.from(nil)
    end
  end

  shared_examples 'a mocked auth object' do
    let(:raw_info) { extra[:raw_info] }

    it 'has the uid' do
      expect(mock_auth.uid).to eq(uid)
    end

    it 'has the email from info' do
      expect(mock_auth.info.email).to eq(info[:email])
    end

    it 'has the username from info' do
      expect(mock_auth.info.username).to eq(info[:username])
    end

    it 'has the name from info' do
      expect(mock_auth.info.name).to eq info[:name]
    end

    it 'has the nickname from info' do
      expect(mock_auth.info.nickname).to eq info[:nickname]
    end

    it 'has the image from info' do
      expect(mock_auth.info.image).to eq info[:image]
    end

    it 'has the email from raw_info' do
      expect(mock_auth.extra.raw_info.email).to eq raw_info[:email]
    end

    it 'has the username from raw_info' do
      expect(mock_auth.extra.raw_info.username).to eq raw_info[:username]
    end

    it 'has the name from raw_info' do
      expect(mock_auth.extra.raw_info.name).to eq raw_info[:name]
    end

    it 'has the nickname from raw_info' do
      expect(mock_auth.extra.raw_info.nickname).to eq raw_info[:nickname]
    end

    it 'has the roles from raw_info' do
      expect(mock_auth.extra.raw_info.roles).to eq raw_info[:roles]
    end

    it 'has the sub from raw_info' do
      expect(mock_auth.extra.raw_info.sub).to eq raw_info[:sub]
    end

    it 'has the user from raw_info' do
      expect(mock_auth.extra.raw_info.user).to eq raw_info[:user]
    end

    it 'has the profile from raw_info' do
      expect(mock_auth.extra.raw_info.profile).to eq raw_info[:profile]
    end

    it 'has the country from raw_info' do
      expect(mock_auth.extra.raw_info.country).to eq raw_info[:country]
    end

    it 'has the country_code from raw_info' do
      expect(mock_auth.extra.raw_info.country_code).to eq raw_info[:country_code]
    end

    it 'has the postcode from raw_info' do
      expect(mock_auth.extra.raw_info.postcode).to eq raw_info[:postcode]
    end
  end

  describe 'OmniAuth::Configuration#add_rpi_mock' do
    subject(:mock_auth) { OmniAuth.config.mock_auth[:rpi] }

    let(:args) { {} }
    let(:uid) { RpiAuthBypass::DEFAULT_UID }
    let(:info) { RpiAuthBypass::DEFAULT_INFO }
    let(:extra) { RpiAuthBypass::DEFAULT_EXTRA }

    before do
      OmniAuth.config.add_rpi_mock(**args)
    end

    it_behaves_like 'a mocked auth object'

    context 'with info and extra specified' do
      let(:uid) { '1d27cca2-fef3-4f79-bc64-b76e93db84a2' }

      let(:info) do
        {
          name: 'Robert Flemming',
          email: 'bob.flemming@example.com',
          username: 'bob.flemming',
          nickname: 'Bob',
          image: 'https://my.avatar.com/image/1'
        }
      end

      let(:extra) do
        { raw_info: {
          country: 'US',
          country_code: 'United States',
          email: info[:email],
          name: info[:name],
          nickname: info[:nickname],
          postcode: '90210',
          profile: 'https://my.user.com/profile/1',
          roles: 'gardener',
          sub: uid,
          user: uid,
          username: info[:username]
        } }
      end
      let(:args) { { uid: uid, info: info, extra: extra } }

      it_behaves_like 'a mocked auth object'
    end
  end
end
