# frozen_string_literal: true

module RpiAuth
  module SpecHelpers
    def stub_auth_for(user:, id_param: :user_id)
      OmniAuth.config.test_mode = true

      expires_in = user.respond_to?(:expires_at) ? user.expires_at.to_i - Time.zone.now.to_i : 3600
      token = user.respond_to?(:access_token) ? user.access_token : SecureRandom.hex(16)
      refresh_token = user.respond_to?(:refresh_token) ? user.refresh_token : SecureRandom.hex(16)

      OmniAuth.config.add_mock(:rpi,
                               uid: user.send(id_param),
                               credentials: {
                                 token: token, refresh_token: refresh_token, expires_in: expires_in
                               }.compact,
                               extra: { raw_info: user.serializable_hash(except: id_param) })
    end

    # This method goes through the login process properly.  In system specs, you
    # need to have visited the page with the "Log in" link before calling this.
    # In request specs, we just post directly to `/auth/rpi`, so this can be
    # called without any prep.
    def sign_in(user:)
      stub_auth_for(user: user)

      # This is a bit grotty, but see if we can call `find_link` (from Capybara,
      # i.e. system specs) first, and then if that fails fall back to using
      # `post` which is available in request specs.
      if respond_to?(:click_on)
        visit('/rpi_auth/test')
        click_on('Log in')
      else
        post '/auth/rpi'
        follow_redirect!
        follow_redirect!
      end
    end
  end
end
