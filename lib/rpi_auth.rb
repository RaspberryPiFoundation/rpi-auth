# frozen_string_literal: true

require 'rpi_auth/version'
require 'rpi_auth/engine'
require 'rpi_auth/configuration'
require 'rpi_auth/models/authenticatable'
require 'rpi_auth/models/with_tokens'
require 'rpi_auth/models/roles'
require 'rpi_auth/models/account_types'
require 'omniauth/rails_csrf_protection'

module RpiAuth
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.user_model
    self.configuration.user_model.constantize
  end
end
