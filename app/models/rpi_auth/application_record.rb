# frozen_string_literal: true

module RpiAuth
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
