# frozen_string_literal: true

require 'spec_helper'

class DummyUser
  include RpiAuth::Models::Authenticatable
end

RSpec.describe RpiAuth::AuthenticationHelper do
  describe '.current_user' do
    context 'when session user is empty' do
      it 'returns nil' do
        expect(helper.current_user).to be_nil
      end
    end

    context 'when session contains user info' do
      let(:user_info) do
        { 'country_code' => 'GB',
          'email' => 'john.doe@example.com',
          'name' => 'John Doe',
          'nickname' => 'John',
          'picture' => 'http://picture.com',
          'profile' => 'http://profile.com',
          'id' => 'userid',
          'roles' => nil }
      end

      before do
        RpiAuth.configuration.user_model = 'DummyUser'
        session[:current_user] = user_info
      end

      after do
        # Reset value or it affects other tests :(
        RpiAuth.configuration.user_model = 'User'
      end

      it 'returns instance of defined user class' do
        expect(helper.current_user).to be_a(DummyUser)
      end

      it 'returns correct values for user' do
        user = helper.current_user
        expect(user.serializable_hash).to match(user_info)
      end
    end
  end
end
