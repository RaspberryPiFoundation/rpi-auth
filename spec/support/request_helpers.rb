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

  def set_session(vars = {})
    post session_path, params: { session_vars: vars }
    expect(response).to have_http_status(:created)

    vars.each_key do |var|
      expect(session[var]).to be_present
    end
  end
end
