# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RpiAuth Test page' do
  let(:user) do
    User.new(user_id: '3ed9b57a-1eb9-42e1-ae54-9a11c930f035')
  end

  before do
    RpiAuth.configuration.user_model = 'User'
  end

  describe 'GET /' do
    context 'when logged out' do
      it 'does not display the user ID' do
        get '/'

        expect(response.body).not_to include(user.user_id)
      end
    end

    context 'when logged in' do
      before do
        sign_in(user)
      end

      it 'displays the user ID' do
        get '/'

        expect(response.body).to include(user.user_id)
      end
    end
  end
end
