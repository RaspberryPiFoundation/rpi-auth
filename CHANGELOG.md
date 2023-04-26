# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.5.0]

### Added

- The `log_out_url` config var can now optionally be set (eg. to the appropriate /oauth2/sessions/logout endpoint once the app's session has been destroyed)

Reference notes: https://github.com/RaspberryPiFoundation/documentation/blob/main/accounts/hydra-v1/logging-out.md

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

## [v1.0.0]

### Added

- Rails 7 / Ruby 3.1 support (these are the only officially supported versions)

## [Unreleased]

### Added

- omniauth-rpi strategy to auth via Hydra1
- include omniauth rails csrf protection
- configuration to allow setting endpoints and credentials for auth
- rails model concern to allow host app to add auth behaviour to a model
- callback, logout and failure routes to handle auth
