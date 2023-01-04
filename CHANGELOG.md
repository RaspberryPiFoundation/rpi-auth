# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
