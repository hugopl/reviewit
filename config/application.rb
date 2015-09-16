require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Configure the status code templates to be served by the app instead of Rack exception application.
    config.exceptions_app = routes

    # Generic email configuration
    if Rails.env.test?
      config.action_mailer.default_url_options = { host: 'example.com' }
      config.action_mailer.default_options = { from: 'reviewit@example.com' }
    else
      yml = YAML.load_file("#{Rails.root}/config/reviewit.yml")['mail']
      yml ||= {}

      config.action_mailer.delivery_method = (yml['delivery_method'] || 'file').to_sym

      config.action_mailer.smtp_settings = {
        address:              yml['address'],
        port:                 yml['port'],
        authentication:       yml['authentication'],
        domain:               yml['domain'],
        enable_starttls_auto: yml['enable_starttls_auto'],
        user_name:            yml['user_name'],
        password:             yml['password'],
        openssl_verify_mode:  yml['openssl_verify_mode']
      }

      config.action_mailer.file_settings = {
        location: 'logs/mails'
      }
      config.action_mailer.default_url_options = {
        host: yml['host']
      }
      config.action_mailer.default_options = {
        from: yml['sender']
      }
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    end
  end
end
