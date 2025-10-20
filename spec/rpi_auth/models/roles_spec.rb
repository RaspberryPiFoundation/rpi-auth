# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RpiAuth::Models::Roles, type: :model do
  subject(:user) { user_class.new(roles:) }

  let(:user_class) do
    Class.new(User) do
      include RpiAuth::Models::Authenticatable
      include RpiAuth::Models::Roles
    end
  end

  describe '#parsed_roles' do
    context 'when roles is set to comma-separated string' do
      let(:roles) { 'role-1,role-2' }

      it 'returns array of role names' do
        expect(user.parsed_roles).to eq(%w[role-1 role-2])
      end
    end

    context 'when roles names have leading & trailing spaces' do
      let(:roles) { ' role-1 , role-2 ' }

      it 'strips the spaces' do
        expect(user.parsed_roles).to eq(%w[role-1 role-2])
      end
    end

    context 'when roles is set to empty string' do
      let(:roles) { '' }

      it 'returns empty array' do
        expect(user.parsed_roles).to eq([])
      end
    end

    context 'when roles is set to nil' do
      let(:roles) { nil }

      it 'returns empty array when roles is set to nil' do
        expect(user.parsed_roles).to eq([])
      end
    end
  end
end
