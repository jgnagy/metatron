# frozen_string_literal: true

module Metatron
  # Extension point for integrating with Rails applications
  class Railtie < ::Rails::Railtie
    initializer "metatron.logger" do
      Metatron.logger = Rails.logger
    end
  end
end
