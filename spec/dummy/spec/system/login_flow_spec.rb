# frozen_string_literal: true

require 'spec_helper'
require 'rpi_auth/spec_helpers'

RSpec.describe 'Login flow' do
  include RpiAuth::SpecHelpers

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

  let(:identity_url) { 'https://my.example.com' }
  let(:session_keys_to_persist) { nil }
  # We need to make sure we match the hostname Rails uses in test requests
  # here, otherwise `returnTo` redirects will fail after login/logout.
  let(:host_url) { 'https://www.example.com' }

  before do
    RpiAuth.configuration.user_model = 'User'
    RpiAuth.configuration.identity_url = identity_url
    RpiAuth.configuration.host_url = host_url
    RpiAuth.configuration.session_keys_to_persist = session_keys_to_persist
    OmniAuth.config.test_mode = true
  end

  describe 'logging in' do
    before do
      stub_auth_for(user: user)
    end

    it do
      visit rpi_auth_test_path(returnTo: rpi_auth_test_path)
      expect(page).to have_no_text(user.user_id)

      click_on 'Log in'
      expect(page).to have_text(user.user_id)
      expect(page).to have_text('Log out')
    end
  end

  describe 'Logging out' do
    before do
      sign_in(user: user)
    end

    it do
      visit rpi_auth_test_path(returnTo: rpi_auth_test_path)
      expect(page).to have_text(user.user_id)
      click_on 'Log out'
      expect(page).to have_no_text(user.user_id)
      expect(page).to have_text('Log in')
    end
  end
end
