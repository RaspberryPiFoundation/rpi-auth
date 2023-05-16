# frozen_string_literal: true

module RequestHelpers
  def stub_auth_for(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:rpi, uid: user.user_id, extra: { raw_info: user.serializable_hash(except: :id) })
  end

  # In request specs, we just post directly to `/auth/rpi`, so this can be
  # called without any prep.
  def sign_in(user)
    stub_auth_for(user)
    post '/auth/rpi'
    follow_redirect!
  end
end
