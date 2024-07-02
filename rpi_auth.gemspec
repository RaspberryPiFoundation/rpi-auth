# frozen_string_literal: true

require_relative 'lib/rpi_auth/version'

Gem::Specification.new do |spec|
  spec.name        = 'rpi_auth'
  spec.version     = RpiAuth::VERSION
  spec.authors     = ['Raspberry Pi Foundation']
  spec.email       = ['web@raspberrypi.org']
  spec.homepage    = 'https://github.com/RaspberryPiFoundation/rpi-auth'
  spec.summary     = 'Auth via Hydra'
  spec.description = 'Auth via Hydra'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/RaspberryPiFoundation/rpi-auth'
  spec.metadata['changelog_uri'] = 'https://github.com/RaspberryPiFoundation/rpi-auth/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.7.7'

  spec.add_dependency 'omniauth_openid_connect', '~> 0.7.1'
  spec.add_dependency 'omniauth-rails_csrf_protection', '~> 1.0.0'
  spec.add_dependency 'rails', '>= 6.1.4'

  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'listen'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
end
