# frozen_string_literal: true

require 'spec_helper'

class DummyUser
  include RpiAuth::Models::Authenticatable
  include RpiAuth::Models::AccountTypes
end

RSpec.describe DummyUser, type: :model do
  subject(:user) { described_class.new(user_id:) }

  describe '#student_account?' do
    context "when user_id has the 'student:' prefix" do
      let(:user_id) { RpiAuth::Models::AccountTypes::STUDENT_PREFIX + SecureRandom.uuid }

      it 'returns truthy' do
        expect(user).to be_student_account
      end
    end

    context "when user_id does not have the 'student:' prefix" do
      let(:user_id) { SecureRandom.uuid }

      it 'returns falsey' do
        expect(user).not_to be_student_account
      end
    end
  end
end
