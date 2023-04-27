# RpiAuth

A gem to handle authenticating via Hydra for Raspberry Pi Foundation Rails applications.

## Usage

The Engine includes the [Rails CSRF protection gem](https://github.com/cookpad/omniauth-rails_csrf_protection), so this does not need to be included in the parent application

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rpi_auth', git: 'https://github.com/RaspberryPiFoundation/rpi-auth.git', tag: 'v1.3.0'
```

And then execute:

```bash
$ bundle
```

Add an initializer file to configure rpi_auth e.g. in `config/initializers/rpi_auth.rb` containing the following information:

```ruby
RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9001'            # The url of Hydra being used
  config.auth_token_url = nil                          # Normally this would be unset, defaulting to AUTH_URL above. When running locally under Docker, set to http://host.docker.internal:9001
  config.auth_client_id = 'gem-dev'                    # The Hydra client ID
  config.auth_client_secret = 'secret'                 # The Hydra client secret
  config.brand = 'brand-name'                          # The brand of the application (see allowed brands in Profile application: app/middleware/brand.js)
  config.host_url = 'http://localhost:3000'            # The url of the host site used (needed for redirects)
  config.identity_url = 'http://localhost:3002'        # The url for the profile instance being used for auth
  config.user_model = 'User'                           # The name of the user model in the host app being used, use the name as a string, not the model itself
  config.scope = 'openid email profile force-consent'  # The required OIDC scopes
  config.success_redirect = '/'                        # After succesful login the route the user should be redirected to; this will override redirecting the user back to where they were when they started the log in / sign up flow (via `omniauth.origin`), so should be used rarely / with caution
  config.bypass_auth = false                           # Should auth be bypassed and a default user logged in
end
```

The values above will allow you to login using the `gem-dev` client seeded in Hydra provided you run the host application on port `3009`.

You will need to change the values to match your application, ideally through ENV vars eg.

```ruby
RpiAuth.configure do |config|
  config.auth_url = ENV.fetch('AUTH_URL', nil)
  config.auth_token_url = ENV.fetch('AUTH_TOKEN_URL', nil)
  config.auth_client_id = ENV.fetch('AUTH_CLIENT_ID', nil)
  config.auth_client_secret = ENV.fetch('AUTH_CLIENT_SECRET', nil)
  config.brand = 'brand-name'
  config.host_url = ENV.fetch('HOST_URL', nil)
  config.identity_url = ENV.fetch('IDENTITY_URL', nil)
  config.user_model = 'User'
  config.scope = 'openid email profile force-consent'
  config.success_redirect = ENV.fetch('OAUTH_SUCCESS_REDIRECT_URL', nil)
  config.bypass_auth = ActiveModel::Type::Boolean.new.cast(ENV.fetch('BYPASS_OAUTH', false))
end
```

Add the helper class to the host application's ApplicationController:

```ruby
class ApplicationController < ActionController::Base
  include RpiAuth::AuthenticationHelper
end
```

This provides access to the `current_user` method in controllers.

Add the `authenticatable` concern to the host application's User model:

```ruby
class User < ApplicationRecord
  extend RpiAuth::Models::Authenticatable
end
```

This model needs to be the same one defined in the initializer, an instance will be created on login.

To login via Hydra your app needs to send the user to `/auth/rpi` via a POST request:

```ruby
<%= link_to 'Log in', '/auth/rpi', method: :post %>
# or:
<%= button_to 'Log in', '/auth/rpi' %>
```

A GET request will be blocked by the CSRF protection gem.

Alternatively, create a dummy route to allow its use in helpers, eg.

```ruby
  # Dummy route. This route is never reached in the app, as RPiAuth / Omniauth gets it
  # before it reaches Rails, however adding this route allows us to use
  # login_path helpers etc.
  post '/auth/rpi', as: 'login'
```

Followed by:

```ruby
<%= link_to 'Log in', login_path, method: :post %>
# or:
<%= button_to 'Log in', login_path %>
```

There is a helper for the logout route:

```ruby
<%= link_to 'Log out', rpi_auth_logout_path  %>
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Local Development

Run:

```bash
$ bundle
```

from the root directory. This will also install the gems required by the dummy application found at `spec/dummy`.

The dummy app can be interacted with in the same way as any Rails application. Go into `spec/dummy` and run commands as normal.

You will need to install the javascript dependencies with `yarn install` first.

The dummy app can be started with `bundle exec rails s -p 3009` and will then be viewable on localhost:3009.
This port matches that set in `spec/dummy/config/initializers/rpi_auth.rb` and will allow redirects to work after logging out using a local installation of Hydra.

There is a simple page at the dummy app root that has a login link and will show a logout link once logged in via Hydra.

If running Hydra locally you will need to configure a new client with the following values:

```ruby
{
  id: 'gem-dev',
  secret: 'secret',
  redirect_urls: 'http://localhost:3009/rpi_auth/auth/callback'
}
```

There is a seed in the Profile repo to set this client up correctly, running the v1 setup tasks will create this client

Ensure to update `lib/rpi_auth/version.rb` when publishing a new version.

### Testing

```bash
$ bundle exec rspec
```

#### Testing with different versions of Rails

This Gem should work with Rails 6.1+, but the `Gemfile.lock` is tracking Rails 7 at the moment. To test Rails 6.1, you'll want to use `gemfiles/rails_6.1.gemfile` as your gemfile, and then run rspec using that.

```
bundle install --gemfile gemfiles/rails_6.1.gemfile
bundle exec --gemfile gemfiles/rails_6.1.gemfile rspec
```

## Releasing

Ensure that the version number has been updated in: https://github.com/RaspberryPiFoundation/rpi-auth/blob/main/lib/rpi_auth/version.rb

Ensure that the changelog has been updated in: https://github.com/RaspberryPiFoundation/rpi-auth/blob/main/CHANGELOG.md

Create and push a new tag from `main`:

```
git tag v1.2.2
git push --tags
```

Create a new release at: https://github.com/RaspberryPiFoundation/rpi-auth/releases/new

Select the newly created tag, the target should be `main`, and the release name should be the same as the tag name eg. `v1.2.2`. Enter a short description of the release (generally best to copy / paste the changelog entry).
