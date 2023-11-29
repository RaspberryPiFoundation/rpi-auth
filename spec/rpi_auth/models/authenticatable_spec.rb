# frozen_string_literal: true

require 'spec_helper'

class DummyUser
  extend RpiAuth::Models::Authenticatable
end

RSpec.describe DummyUser, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:country) }
  it { is_expected.to respond_to(:country_code) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:nickname) }
  it { is_expected.to respond_to(:picture) }
  it { is_expected.to respond_to(:profile) }

  describe '#from_omniauth' do
    subject(:omniauth_user) { described_class.from_omniauth(auth) }

    let(:info) do
      {
        email: 'test@example.com',
        name: 'Bodkin Van Horn',
        nickname: 'Hoos-Foos',
        country: 'Zimbabwe',
        country_code: 'ZW',
        picture: 'https://placecage.com/100/100',
        profile: 'https://my.raspberry.pi/profile/edit'
      }
    end

    let(:auth) do
      OmniAuth::AuthHash.new(
        {
          provider: 'rpi',
          uid: 'testuserid',
          extra: {
            raw_info: info
          }
        }
      )
    end

    it 'returns a user with the correct attributes' do
      expect(omniauth_user).to be_a described_class
      expect(omniauth_user).to have_attributes(user_id: 'testuserid', name: 'Bodkin Van Horn',
                                               nickname: 'Hoos-Foos', email: 'test@example.com',
                                               country: 'Zimbabwe', country_code: 'ZW',
                                               picture: 'https://placecage.com/100/100',
                                               profile: 'https://my.raspberry.pi/profile/edit')
    end

    context 'with unusual keys in info' do
      let(:info) { { foo: :bar, flibble: :woo } }

      it { is_expected.to be_a described_class }
    end

    context 'with no info' do
      let(:info) { nil }

      it { is_expected.to be_a described_class }
    end

    context 'with no auth set' do
      let(:auth) { nil }

      it { is_expected.to be_nil }
    end
  end
end
