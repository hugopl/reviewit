Rails.application.configure do
  break if Rails.env.test?

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
    location: (yml['store_location'] || '/tmp/mails')
  }
  config.action_mailer.default_url_options = {
    host: yml['host']
  }
  config.action_mailer.default_options = {
    from: yml['sender']
  }
end
