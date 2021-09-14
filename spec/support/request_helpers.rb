# frozen_string_literal: true

module RequestHelpers
  def sign_in(user)
    OmniAuth.config.add_mock(:rpi, uid: user[:id], extra: { raw_info: user.except(:id) })
    post '/auth/rpi'
    follow_redirect!
  end
end
