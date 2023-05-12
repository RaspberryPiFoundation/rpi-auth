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
    username: DEFAULT_USERNAME,
    image: DEFAULT_IMAGE
  }.freeze
  DEFAULT_EXTRA = {
    raw_info: {
      roles: DEFAULT_ROLES,
      name: DEFAULT_NAME,
      nickname: DEFAULT_NICKNAME,
      email: DEFAULT_EMAIL,
      username: DEFAULT_USERNAME,
      country: DEFAULT_COUNTRY,
      country_code: DEFAULT_COUNTRY_CODE,
      postcode: DEFAULT_POSTCODE,
      profile: DEFAULT_PROFILE,
      avatar: DEFAULT_IMAGE
    }
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

    def add_rpi_mock(uid: RpiAuthBypass::DEFAULT_UID, info: RpiAuthBypass::DEFAULT_INFO,
                     extra: RpiAuthBypass::DEFAULT_EXTRA)
      add_mock(:rpi, {
                 provider: 'Rpi',
                 uid: uid,
                 info: info,
                 extra: extra
               })
    end

    attr_writer :rpi_auth_bypass
  end
end
