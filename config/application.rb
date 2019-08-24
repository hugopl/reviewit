require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require File.expand_path('../../app/models/reviewit_config.rb', __FILE__)

module Reviewit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the status code templates to be served by the app instead of Rack exception application.
    config.exceptions_app = routes

    # Generic email configuration
    if Rails.env.test?
      config.action_mailer.default_url_options = { host: 'example.com' }
      config.action_mailer.default_options = { from: 'reviewit@example.com' }
    else
      delivery_method = ReviewitConfig.mail.delivery_method.to_sym
      config.action_mailer.delivery_method = delivery_method

      config.action_mailer.smtp_settings = {
        address: ReviewitConfig.mail.address,
        port: ReviewitConfig.mail.port,
        enable_starttls_auto: ReviewitConfig.mail.enable_starttls_auto,
        user_name: ReviewitConfig.mail.user_name,
        password: ReviewitConfig.mail.password
      }

      config.action_mailer.file_settings = { location: 'logs/mails' } if delivery_method == :file

      config.action_mailer.default_url_options = {
        host: ReviewitConfig.mail.host
      }
      config.action_mailer.default_options = {
        from: ReviewitConfig.mail.sender
      }
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    end
  end
end
