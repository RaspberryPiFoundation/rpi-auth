# RpiAuth

A gem to handle OpenID Connect authentication via Hydra for Raspberry Pi Foundation Rails applications.

## Usage

The Engine includes the [Rails CSRF protection gem](https://github.com/cookpad/omniauth-rails_csrf_protection), so this does not need to be included in the parent application

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rpi_auth', git: 'https://github.com/RaspberryPiFoundation/rpi-auth.git', tag: 'v3.2.0'
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
  config.success_redirect = '/'                        # After succesful login the route the user should be redirected to; this will override redirecting the user back to where they were when they started the log in / sign up flow (via `omniauth.origin`), so should be used rarely / with caution.  This can be a string or a proc, which is executed in the context of the RpiAuth::AuthController.
  config.bypass_auth = false                           # Should auth be bypassed and a default user logged in
end
```

The values above will allow you to login using the `gem-dev` client seeded in Hydra provided you run the host application on port `3009`.  An example configuration can be found [in the dummy app](spec/dummy/config/initializers/rpi_auth.rb).

You will need to change the values to match your application, ideally through ENV vars eg.

```ruby
RpiAuth.configure do |config|
  config.auth_url = ENV.fetch('AUTH_URL', nil)
  config.auth_token_url = ENV.fetch('AUTH_TOKEN_URL', nil)
  config.auth_client_id = ENV.fetch('AUTH_CLIENT_ID', nil)
  config.auth_client_secret = ENV.fetch('AUTH_CLIENT_SECRET', nil)
  config.brand = 'raspberrypi-org'
  config.host_url = ENV.fetch('HOST_URL', nil)
  config.identity_url = ENV.fetch('IDENTITY_URL', nil)
  config.user_model = 'User'
  config.scope = 'openid email profile force-consent'
  config.success_redirect = ENV.fetch('OAUTH_SUCCESS_REDIRECT_URL', nil)
  config.bypass_auth = ActiveModel::Type::Boolean.new.cast(ENV.fetch('BYPASS_OAUTH', false))
end
```

Add the `CurrentUser` concern to the host application's ApplicationController:

```ruby
class ApplicationController < ActionController::Base
  include RpiAuth::Controllers::CurrentUser
end
```

This provides access to the `current_user` method in controllers and helpers.  The dummy app [has an example of this](spec/dummy/app/controllers/application_controller.rb).

Add the `authenticatable` concern to the host application's User model:

```ruby
class User < ApplicationRecord
  include RpiAuth::Models::Authenticatable
end
```

This model needs to be the same one defined in the initializer, an instance will be created on login.  Again, checkout the [user model in the dummy app](spec/dummy/app/models/user.rb).

To login via Hydra your app needs to send the user to `/auth/rpi` via a POST request:

```ruby
link_to 'Log in', '/auth/rpi', method: :post
# or:
button_to 'Log in', '/auth/rpi'
```

A GET request will be blocked by the CSRF protection gem.

Alternatively you can use the path helpers:

```ruby
link_to 'Log in', rpi_auth_login_path, method: :post
# or:
button_to 'Log in', rpi_auth_login_path
```

There is a helper for the sign-up buttons, which pushes the user through the sign-up flow.

```ruby
button_to 'Sign up', rpi_auth_signup_path
```

And there is also a helper for the logout route:

```ruby
link_to 'Log out', rpi_auth_logout_path
```

### Redirecting users to the "next step"

There are a three possible places the user will end up at following logging in,
in the following order:

1. The `success_redirect` URL or proc.
2. The specified `returnTo` URL.
3. The page the user was on (if the Referer header is sent in).
4. The root path of the application.

Note that none of these places can be on a different host, i.e. they have to be
inside your application.

The `success_redirect` set in the RpiAuth configuration block will trump
everything, so only use this configuration option if you always want your users
to end up at the same place.

If you wish to redirect users to the next step in the process, e.g. to a
registration form, then you should supply a parameter called `returnTo` which
is then used to redirect after log in/sign up are successful.

```ruby
button_to 'Log in to start registraion', rpi_auth_login_path, params: { returnTo: '/registration_form' }
```

If this parameter is missing [Omniauth uses the HTTP Referer
header](https://github.com/omniauth/omniauth/blob/d2fd0fc80b0342046484b99102fa00ec5b5392ff/lib/omniauth/strategy.rb#L252-L256)
meaning (most) users will end up back on the page where they started the auth flow (this is often the most preferable situation).

Finally, if none of these things are set, we end up back at the application root.

#### Advanced customisation of the login redirect

On occasion you may wish to heavily customise the way the login redirect is handled.  For example, you may wish to redirect to something a bit more dynamic than either the static `success_redirect` or original HTTP referer/`returnTo` parameter.

Fear not! You can set `success_redirect` to a Proc in the configuration, which will then be called in the context of the request.

```ruby
config.success_redirect = -> { request.env['omniauth.origin'] + "?cache_bust=#{Time.now.to_i}&username=#{current_user.nickname}" }
```

will redirect the user to there `/referer/url?cache_bust=1231231231`, if they started the login process from `/referer/url` page.  The proc can return a string or a nil.  In the case of a nil, the user will be redirected to the `returnTo` parameter.  The return value will be checked to make sure it is local to the app.  You cannot redirect to other URLs/hosts with this technique.

You can use variables and methods here that are available in the [RpiAuth::AuthController](app/controllers/rpi_auth/auth_controller.rb), i.e. things like
* `current_user` -- the current logged in user.
* `request.env['omniauth.origin']` (the original `returnTo` value)

**Beware** here be dragons! 🐉 You might get difficult-to-diagnose bugs using this technique.  The Proc in your configuration may be tricky to test, so keep it simple.  If your Proc raises an exception, the URL returned will default to `/` and there should be a warning in the Rails log saying what happened.

When using this, you will find that Rails needs to be restarted when you change the proc, as the configuration block is only evaluated on start-up.

#### Redirecting when logging out

It is also possible to send users to pages within your app when logging out.  Just set the `returnTo` parameter again.

```ruby
link_to 'Log out', rpi_auth_logout_path, params: { returnTo: '/thanks-dude' }
```

This has to be a relative URL, i.e. it has to start with a slash.  This is to ensure there's no open redirect.

### Globbed/catch-all routes

If your app has a catch-all route at the end of the routing table, you must
shuffle Rails Engine loading order, putting `RpiAuth::Engine` above the default
engines.  To do this add a `config.railties_order` line in the Application
class in `config/application.rb`.

```ruby
# If there is a globbed route in the route file, (e.g. `get /*slug, ...`)
# we need to make sure that the RpiAuth routes take precedence over that
# route, otherwise the globbed route will catch all the routes defined in
# the engine.
#
# See https://api.rubyonrails.org/classes/Rails/Engine.html#class-Rails::Engine-label-Loading+priority
config.railties_order = [RpiAuth::Engine, :main_app, :all]
```

## Troubleshooting

Diagnosing issues with OpenID Connect can be tricky, so here are some things to try.

### Setting the token URL in development mode

Typically we run both Profile/Hydra and our applications in Docker.  Both the browser and the application have to communicate with Hydra, and in a docker situation this means using two different hostnames.  The browser can use `localhost`, but inside docker containers `localhost` refers to the container itself, not the machine running Docker.  So the container has to use `docker.host.internal` instead.  As a result, the application needs to have a separate URL to check tokens on.  We configure this as the `auth_token_url`.

Typical local environment variables for development are

```
AUTH_CLIENT_ID=my-hydra-client-dev
AUTH_CLIENT_SECRET=1234567890
AUTH_TOKEN_URL=http://host.docker.internal:9001/
AUTH_URL=http://localhost:9001     # The URL where Hydra is running
HOST_URL=http://localhost:3000     # The URL where your app is running
IDENTITY_URL=http://localhost:3002 # The URL where Profile (Pi Accounts) is running
```

### Matching the Issuer

When tokens are issued, the OpenID Connect library validates that the token's "issuer" (`iss`) value.  This library assumes that it matches the `auth_url` value, complete with a trailing slash.  If this is not the case, you can set the issuer manually.  It should match the value in either the `docker-compose.yml` in the profile repo, or at `http://localhost:9001/.well-known/openid-configuration` when Hydra is running.

### Discovery

The Omniauth OpenID Connect gem can use discovery to work out the majority of the configuration.  However this does not work in development, as the discovery URL is assumed to be available over HTTPS which is not the case in this scenario.

## Upgrading between versions.

This project follows semantic versioning, so upgrades between minor and patch
versions should not need any code or configuration changes.

For major version upgrades see the [upgrading docs](UPGRADING.md).

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
