require_relative 'lib/rpi_auth/version'

Gem::Specification.new do |spec|
  spec.name        = 'rpi_auth'
  spec.version     = RpiAuth::VERSION
  spec.authors     = ['Raspberry Pi Foundation']
  spec.email       = ['web@raspberrypi.org']
  spec.homepage    = 'https://www.raspberrypi.org'
  spec.summary     = 'Auth via Hydra'
  spec.description = 'Auth via Hydra'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'omniauth-rails_csrf_protection', '~> 1.0.0'
  spec.add_dependency 'omniauth-rpi'
  spec.add_dependency 'rails', '~> 6.1.4', '>= 6.1.4.1'

  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'listen'
  spec.add_development_dependency 'webpacker', '~> 5.0'
  spec.add_development_dependency 'turbolinks', '~> 5'
end
