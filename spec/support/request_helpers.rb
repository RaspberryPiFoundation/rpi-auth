# frozen_string_literal: true

module RequestHelpers
  def set_session(vars = {})
    post session_path, params: { session_vars: vars }
    expect(response).to have_http_status(:created)

    vars.each_key do |var|
      expect(session[var]).to be_present
    end
  end
end
