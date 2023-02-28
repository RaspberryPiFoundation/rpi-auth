# RpiAuth

A gem to handle authenticating via Hydra for Raspberry Pi Foundation Rails applications.

## Usage

The Engine includes the [Rails CSRF protection gem](https://github.com/cookpad/omniauth-rails_csrf_protection), so this does not need to be included in the parent application

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rpi_auth', git: 'https://github.com/RaspberryPiFoundation/rpi-auth.git', tag: 'v1.0.1'
```

And then execute:
```bash
$ bundle
```

Add an initializer file to configure rpi_auth e.g. in `config/initializers/rpi_auth.rb` containing the following information:

```ruby
RpiAuth.configure do |config|
  config.auth_url = 'http://localhost:9000'         # The url of hydra being used
  config.auth_client_id = 'gem-dev'                 # The hydra client ID
  config.auth_client_secret = 'secret'              # The hydra client secret
  config.host_url = 'http://localhost:3009'         # The url of the host site used (needed for redirects)
  config.identity_url = 'http://localhost:3002'     # The url for the profile instance being used for auth
  config.user_model = 'User'                        # The name of the user model in the host app being used, use the name as a string, not the model itself
  config.success_redirect = '/'                     # After succesful login the route the user should be redirected to
  config.bypass_auth = false                        # Should auth be bypassed and a default user logged in
end
```

The values above will allow you to login using the `gem-dev` client seeded in Hydra provided you run the host application on port `3009`.
You will need to change the values to match your application.

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
  include RpiAuth::Models::Authenticatable
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
There is a seed in the profile repo to set this client up correctly, running the v1 setup tasks will create this client

### Testing with different versions of rails

This Gem should work with Rails 6.1+, but the `Gemfile.lock` is tracking rails 7 at the moment.  To test rails 6.1, you'll want to use `gemfiles/rails_6.1.gemfile` as your gemfile, and then run rspec using that.

```
bundle install --gemfile gemfiles/rails_6.1.gemfile
bundle exec --gemfile gemfiles/rails_6.1.gemfile rspec
```

