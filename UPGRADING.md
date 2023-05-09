# Upgrading rpi-auth

Here are the details of the changes needed when upgrading between major versions of this gem.

## v1 to v2

Definitely change the following:

1. [ ] Replace references to `RpiAuth::AuthenticationHelper` with `RpiAuth::Controllers::CurrentUser`.
2. [ ] Change `extend RpiAuth::Models::Authenticatable` to `include RpiAuth::Models::Authenticatable`.

You might also need to;

* [ ] Remove dummy `login` route in `/config/routes.rb`, and replace references to `login_path` with `rpi_auth_login_path`.
* [ ] Change [the railties order](https://github.com/RaspberryPiFoundation/rpi-auth/blob/v2.0.0/README.md#globbedcatch-all-routes) if your app uses globbed/catch-all routes



