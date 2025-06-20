# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed

### Removed

## [v4.2.0]

### Added

- Allow OmniAuth setup phase to be configured (#76)
- Add `RpiAuth::Models::Roles#parsed_roles` (extracted from experience-cs) (#87)
- Add `RpiAuth::Models::AccountTypes#student_account?` (extracted from experience-cs) (#87)

## [v4.1.1]

### Fixed

- Fix requiring of oauth2 to avoid `NoMethodError: undefined method 'config' for module OAuth2` (#86)

## [v4.1.0]

### Added
- Add access token-related functionality including auto-refresh (#83)

### Fixed
- Fix use of `User#expires_at` in `SpecHelpers#stub_auth_for` (#82)

## [v4.0.0]

### Added
- Support for Ruby 3.3 (#78)

### Fixed
- Load error when using Rake (#77)
- Don't use cached user if session has been reset (#79)

### Removed
- Support for Ruby 2.7 (#78)

## [v3.6.0]

### Added
- Test controller/view to allow apps to log in without having to interact with the RPF Global Nav component. (#70)

## [v3.5.0]

### Added

- `session_keys_to_persist` config option to allow for specific session keys to be persisted across logins (since logging in will reset the session: https://guides.rubyonrails.org/security.html#session-fixation-countermeasures)

## [v3.4.0]

### Removed

- `v1_signup` param as it is no longer needed (https://github.com/RaspberryPiFoundation/profile/pull/1512)

## [v3.3.0]

### Added

- Add country attribute to `Authenticable` (#60)

## [v3.2.0]

### Added

- Allow for customisation of returnTo param on log out (#56)
- Allow `success_redirect` to be configured as a block that is executed in the context of the AuthController (#57)

## [v3.1.0]

### Changed

- Altered default value of the `issuer` to track the `authorization_endpoint` rather than the `token_endpoint` (#54)

### Fixed

- Ensure `redirect_uri` is set in the OpenID Connect configuration (#53)

## [v3.0.0]

### Changed

- Replaced usage of [omniauth-rpi](https://github.com/RaspberryPiFoundation/omniauth-rpi/) strategy with [omniauth_openid_connect](https://github.com/omniauth/omniauth_openid_connect/) (#51)

## [v2.0.0]

### Added
- Added dummy route for `/auth/rpi` to add path helper `rpi_auth_login` (#44)
- Request and routing specs inside the "dummy" testing app (#44)

### Changed
- Refactored `RpiAuth::AuthenticationHelper` into a concern RpiAuth::Controllers::CurrentUser (#44)
- Refactored `RpiAuth::Models::Authenticatable` to fix "include"/"extend" issues (#44)
- Refactored `RpiAuth::AuthController#callback` to reduce its complexity (#44)
- Refactored how auth bypass is enabled (#44)
- OmniAuth origin parameter name set as `returnTo` (#47)

## Updated

- Bump rack from 2.2.4 to 2.2.7 (#49)
- Bump globalid from 1.0.0 to 1.1.0 (#48)

## [v1.4.0]

### Added

- The `brand` parameter can now optionally be set (for use by the Profile application)

## [v1.3.0]

### Added

- Make `RpiAuth::Models::Authenticatable` extendable to support additional methods and attributes in the `user_model`.

## [v1.2.1]

### Added

- Removed default setting of `success_redirect = '/'` in RpiAuth config

## [v1.2.0]

### Added

- omniauth-rpi gem updated to fix nil user ID in returned user object

## [v1.1.0]

- Defaults to setting the `user_id` param on the model rather than id (so that the application can use an internal ID structure for the user model).

## [v1.0.1]

- Updates Omniauth-rpi to latest version (fixing a bug where the returbed uid was empty)

## [v1.0.0]

### Added

- Rails 7 / Ruby 3.1 support (these are the only officially supported versions)
- omniauth-rpi strategy to auth via Hydra1
- include omniauth rails csrf protection
- configuration to allow setting endpoints and credentials for auth
- rails model concern to allow host app to add auth behaviour to a model
- callback, logout and failure routes to handle auth

[Unreleased]: https://github.com/RaspberryPiFoundation/rpi-auth/compare/v4.2.0...HEAD
[v4.2.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v4.2.0
[v4.1.1]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v4.1.1
[v4.1.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v4.1.0
[v4.0.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v4.0.0
[v3.6.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.6.0
[v3.5.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.5.0
[v3.4.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.4.0
[v3.3.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.3.0
[v3.2.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.2.0
[v3.1.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.1.0
[v3.0.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v3.0.0
[v2.0.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v2.0.0
[v1.4.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.4.0
[v1.3.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.3.0
[v1.2.1]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.2.1
[v1.2.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.2.0
[v1.1.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.1.0
[v1.0.1]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.0.1
[v1.0.0]: https://github.com/RaspberryPiFoundation/rpi-auth/releases/tag/v1.0.0
