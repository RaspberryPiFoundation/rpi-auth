# RpiAuth

A gem to handle authenticating via Hydra for Raspberry Pi Foundation Rails applications.

## Usage

How to use my plugin.

The Engine includes the [Rails CSRF protection gem](https://github.com/cookpad/omniauth-rails_csrf_protection), so this does not need to be included in the parent application

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rpi_auth'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rpi_auth
```

## Contributing
Contribution directions go here.

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
Follow the instructions in the Profile repository to do this.
