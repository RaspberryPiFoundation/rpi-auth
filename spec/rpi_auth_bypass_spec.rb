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

  describe 'OmniAuth::Configuration#add_rpi_mock' do
    subject(:mock_auth) { OmniAuth.config.mock_auth[:rpi] }

    let(:args) { {} }

    before do
      OmniAuth.config.add_rpi_mock(**args)
    end

    it 'has the default uid' do
      expect(mock_auth.uid).to eq(RpiAuthBypass::DEFAULT_UID)
    end

    it 'has the default email' do
      expect(mock_auth.info.email).to eq(RpiAuthBypass::DEFAULT_EMAIL)
    end

    it 'has the default username' do
      expect(mock_auth.info.username).to eq(RpiAuthBypass::DEFAULT_USERNAME)
    end

    it 'has the default name' do
      expect(mock_auth.info.name).to eq(RpiAuthBypass::DEFAULT_NAME)
    end

    it 'has the default nickname' do
      expect(mock_auth.info.nickname).to eq(RpiAuthBypass::DEFAULT_NICKNAME)
    end

    it 'has the default image' do
      expect(mock_auth.info.image).to eq(RpiAuthBypass::DEFAULT_IMAGE)
    end

    it 'has the default roles' do
      expect(mock_auth.extra.raw_info.roles).to eq(RpiAuthBypass::DEFAULT_ROLES)
    end

    it 'has the default avatar' do
      expect(mock_auth.extra.raw_info.avatar).to eq(RpiAuthBypass::DEFAULT_IMAGE)
    end

    it 'has the default profile' do
      expect(mock_auth.extra.raw_info.profile).to eq(RpiAuthBypass::DEFAULT_PROFILE)
    end

    it 'has the default country' do
      expect(mock_auth.extra.raw_info.country).to eq(RpiAuthBypass::DEFAULT_COUNTRY)
    end

    it 'has the default country code' do
      expect(mock_auth.extra.raw_info.country_code).to eq(RpiAuthBypass::DEFAULT_COUNTRY_CODE)
    end

    it 'has the default postcode' do
      expect(mock_auth.extra.raw_info.postcode).to eq(RpiAuthBypass::DEFAULT_POSTCODE)
    end

    context 'with info and extra specified' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:uid) { '1d27cca2-fef3-4f79-bc64-b76e93db84a2' }
      let(:name) { 'Robert Flemming' }
      let(:nickname) { 'Bob' }
      let(:email) { 'bob.flemming@example.com' }
      let(:username) { 'bob.flemming' }
      let(:roles) { 'gardener' }
      let(:image) { 'https://my.avatar.com/image/1' }
      let(:profile) { 'https://my.user.com/profile/1' }
      let(:country) { 'United States' }
      let(:country_code) { 'US' }
      let(:postcode) { '123456' }

      let(:info) { { name: name, email: email, username: username, nickname: nickname, image: image } }
      let(:extra) do
        { raw_info: {
          name: name,
          email: email,
          username: username,
          nickname: nickname,
          roles: roles,
          avatar: image,
          profile: profile,
          country: country,
          country_code: country_code,
          postcode: postcode
        } }
      end
      let(:args) { { uid: uid, info: info, extra: extra } }

      it 'has the uid' do
        expect(mock_auth.uid).to eq(uid)
      end

      it 'has the email from info' do
        expect(mock_auth.info.email).to eq(email)
      end

      it 'has the username from info' do
        expect(mock_auth.info.username).to eq(username)
      end

      it 'has the name from info' do
        expect(mock_auth.info.name).to eq(name)
      end

      it 'has the nickname from info' do
        expect(mock_auth.info.nickname).to eq(nickname)
      end

      it 'has the image from info' do
        expect(mock_auth.info.image).to eq(image)
      end

      it 'has the email from extra' do
        expect(mock_auth.extra.raw_info.email).to eq(email)
      end

      it 'has the username from extra' do
        expect(mock_auth.extra.raw_info.username).to eq(username)
      end

      it 'has the name from extra' do
        expect(mock_auth.extra.raw_info.name).to eq(name)
      end

      it 'has the nickname from extra' do
        expect(mock_auth.extra.raw_info.nickname).to eq(nickname)
      end

      it 'has the roles from extra' do
        expect(mock_auth.extra.raw_info.roles).to eq(roles)
      end

      it 'has the avatar from extra' do
        expect(mock_auth.extra.raw_info.avatar).to eq(image)
      end

      it 'has the profile from extra' do
        expect(mock_auth.extra.raw_info.profile).to eq(profile)
      end

      it 'has the country from extra' do
        expect(mock_auth.extra.raw_info.country).to eq(country)
      end

      it 'has the country_code from extra' do
        expect(mock_auth.extra.raw_info.country_code).to eq(country_code)
      end

      it 'has the postcode from extra' do
        expect(mock_auth.extra.raw_info.postcode).to eq(postcode)
      end
    end
  end
end
