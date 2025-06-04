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
