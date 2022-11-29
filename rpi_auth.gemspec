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

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'omniauth-rails_csrf_protection', '~> 1.0.0'
  spec.add_dependency 'omniauth-rpi', '~> 1.1'
  spec.add_dependency 'rails', '~> 7.0'

  spec.add_development_dependency 'listen', '~> 3.7.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.9.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'rspec-rails', '~> 4.1.2'
  spec.add_development_dependency 'rubocop', '~> 1.20.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.11.5'
  spec.add_development_dependency 'rubocop-rails', '~> 2.15.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
end
