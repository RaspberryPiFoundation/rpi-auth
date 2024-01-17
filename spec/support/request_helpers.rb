# frozen_string_literal: true

module RequestHelpers
  def sign_in(user)
    OmniAuth.config.add_mock(:rpi, uid: user[:user_id], extra: { raw_info: user.except(:user_id) })
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
