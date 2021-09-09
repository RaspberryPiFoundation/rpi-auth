require 'spec_helper'

class DummyUser
  include RpiAuth::Models::Authenticatable
end

RSpec.describe RpiAuth do
  describe '.user_model' do
    before do
      RpiAuth.configuration.user_model = 'DummyUser'
    end

    after do
      # Reset value or it affects other tests :(
      RpiAuth.configuration.user_model = 'User'
    end

    it 'returns the constantized class defined by config' do
      expect(RpiAuth.user_model).to eq(DummyUser)
    end

    context 'when class defined in config does not exist' do
      before do
        RpiAuth.configuration.user_model = 'WrongUser'
      end

      it 'throws uninitialized constant error' do
        expect { RpiAuth.user_model }.to raise_error(NameError, 'uninitialized constant WrongUser')
      end
    end
  end
end
