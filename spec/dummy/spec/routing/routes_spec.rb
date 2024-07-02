# frozen_string_literal: true

RSpec.describe 'Authentication routing' do
  # If you need to work out what the routing looks like, you can use this to print it out in an example
  #
  # routes = Rails.application.routes.routes
  # inspector = ActionDispatch::Routing::RoutesInspector.new(routes)
  # puts inspector.format(ActionDispatch::Routing::ConsoleFormatter::Sheet.new)

  describe 'a random page' do
    subject { { get: '/foo' } }

    it { is_expected.to route_to({ controller: 'home', action: 'show', slug: 'foo' }) }
  end

  describe 'log out' do
    subject { { get: '/rpi_auth/logout' } }

    it { is_expected.to route_to({ controller: 'rpi_auth/auth', action: 'destroy' }) }
  end

  describe 'auth callback' do
    subject { { get: '/rpi_auth/auth/callback' } }

    it { is_expected.to route_to({ controller: 'rpi_auth/auth', action: 'callback' }) }
  end

  describe 'test login page' do
    subject { { get: '/rpi_auth/test' } }

    let(:enable_test_path) { true }

    before do
      stub_const('RpiAuth::Engine::ENABLE_TEST_PATH', enable_test_path)
      Rails.application.reload_routes!
    end

    after do
      stub_const('RpiAuth::Engine::ENABLE_TEST_PATH', true)
      Rails.application.reload_routes!
    end

    it { is_expected.to route_to({ controller: 'rpi_auth/test', action: 'show' }) }

    context 'when test path is disabled' do
      let(:enable_test_path) { false }

      it { is_expected.not_to be_routable }
    end
  end
end
