# frozen_string_literal: true

require 'omniauth'

RSpec.configure do |config|
  config.around do |example|
    original_value = OmniAuth.config.test_mode
    begin
      example.run
    ensure
      OmniAuth.config.test_mode = original_value
    end
  end
end
