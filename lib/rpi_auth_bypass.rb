# frozen_string_literal: true

module RpiAuthBypass
  DEFAULT_UID = 'b6301f34-b970-4d4f-8314-f877bad8b150'
  DEFAULT_EMAIL = 'web@raspberrypi.org'
  DEFAULT_USERNAME = 'webteam'
  DEFAULT_NAME = 'Web Team'
  DEFAULT_NICKNAME = 'Web'
  DEFAULT_PROFILE = 'https://profile.raspberrypi.org/not/a/real/path'
  DEFAULT_IMAGE = 'https://www.placecage.com/200/200'
  DEFAULT_ROLES = 'user'
  DEFAULT_COUNTRY = 'United Kingdom'
  DEFAULT_COUNTRY_CODE = 'GB'
  DEFAULT_POSTCODE = 'SW1A 1AA'

  DEFAULT_INFO = {
    name: DEFAULT_NAME,
    nickname: DEFAULT_NICKNAME,
    email: DEFAULT_EMAIL,
    email_verified: true,
    username: DEFAULT_USERNAME,
    image: DEFAULT_IMAGE
  }.freeze

  DEFAULT_EXTRA = {
    raw_info: {
      country: DEFAULT_COUNTRY,
      country_code: DEFAULT_COUNTRY_CODE,
      email: DEFAULT_EMAIL,
      email_verified: true,
      name: DEFAULT_NAME,
      nickname: DEFAULT_NICKNAME,
      picture: DEFAULT_IMAGE,
      postcode: DEFAULT_POSTCODE,
      profile: DEFAULT_PROFILE,
      roles: DEFAULT_ROLES,
      sub: DEFAULT_UID,
      user: DEFAULT_UID,
      username: DEFAULT_USERNAME
    }
  }.freeze

  DEFAULT_CREDENTIALS = {
    id_token: 'dummy-id-token',
    token: 'dummy-access-token',
    refresh_token: 'dummy-refresh-token',
    expires_in: 3600,
    scope: 'openid email profile force-consent roles offline'
  }.freeze

  refine OmniAuth::Configuration do
    def enable_rpi_auth_bypass
      logger.info 'Enabling RpiAuthBypass'
      add_rpi_mock unless @mock_auth[:rpi]

      self.test_mode = self.rpi_auth_bypass = true
    end

    def disable_rpi_auth_bypass
      logger.debug 'Disabing RpiAuthBypass'
      @mock_auth.delete(:rpi)

      self.test_mode = self.rpi_auth_bypass = false
    end

    def add_rpi_mock(uid: RpiAuthBypass::DEFAULT_UID,
                     info: RpiAuthBypass::DEFAULT_INFO,
                     extra: RpiAuthBypass::DEFAULT_EXTRA,
                     credentials: RpiAuthBypass::DEFAULT_CREDENTIALS)
      add_mock(:rpi, {
                 provider: :rpi,
                 uid:,
                 info:,
                 extra:,
                 credentials:
               })
    end

    attr_writer :rpi_auth_bypass
  end
end
