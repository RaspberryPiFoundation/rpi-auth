# frozen_string_literal: true

module RpiAuth
  class ApplicationController < ActionController::Base
    include RpiAuth::CurrentUserConcern
  end
end
