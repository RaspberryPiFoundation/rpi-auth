# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RpiAuth::Models::AccountTypes, type: :model do
  subject(:user) { user_class.new(user_id:) }

  let(:user_class) do
    Class.new(User) do
      include RpiAuth::Models::Authenticatable
      include RpiAuth::Models::AccountTypes
    end
  end

  describe '#student_account?' do
    context "when user_id has the 'student:' prefix" do
      let(:user_id) { RpiAuth::Models::AccountTypes::STUDENT_PREFIX + SecureRandom.uuid }

      it 'returns true' do
        expect(user.student_account?).to be(true)
      end
    end

    context "when user_id does not have the 'student:' prefix" do
      let(:user_id) { SecureRandom.uuid }

      it 'returns false' do
        expect(user.student_account?).to be(false)
      end
    end

    context 'when user_id is not set' do
      let(:user_id) { nil }

      it 'returns false' do
        expect(user.student_account?).to be(false)
      end
    end
  end
end
