# frozen_string_literal: true

require 'spec_helper'

# These tests just make sure our path helpers are working as expected.
RSpec.describe 'home/show' do
  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end
  end

  let(:html) { Nokogiri::HTML(rendered) }

  context 'when logged out' do
    let(:user) { nil }

    it 'shows the correct log in link' do
      render
      expect(html.search('a[href="/auth/rpi"]')).not_to be_empty
    end
  end

  context 'when logged in' do
    let(:user) { User.new(user_id: 'xyz') }

    it 'shows the correct log out link' do
      render
      expect(html.search('a[href="/rpi_auth/logout"]')).not_to be_empty
    end
  end
end
