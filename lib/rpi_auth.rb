require 'rpi_auth/version'
require 'rpi_auth/engine'
require 'rpi_auth/configuration'
require 'rpi_auth/models/authenticatable'

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
