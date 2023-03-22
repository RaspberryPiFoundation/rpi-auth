# frozen_string_literal: true

require 'spec_helper'

class DummyUser
  extend RpiAuth::Models::Authenticatable
end

RSpec.describe RpiAuth do
  describe '.user_model' do
    before do
      described_class.configuration.user_model = 'DummyUser'
    end

    after do
      # Reset value or it affects other tests :(
      described_class.configuration.user_model = 'User'
    end

    it 'returns the constantized class defined by config' do
      expect(described_class.user_model).to eq(DummyUser)
    end

    context 'when class defined in config does not exist' do
      before do
        described_class.configuration.user_model = 'WrongUser'
      end

      it 'throws uninitialized constant error' do
        expect { described_class.user_model }.to raise_error(NameError, 'uninitialized constant WrongUser')
      end
    end
  end
end
