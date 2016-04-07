require 'fileutils'
require 'securerandom'

DATABASE_YML = <<eos
production:
  adapter: postgresql
  encoding: UTF8
  database: reviewit
development:
  adapter: postgresql
  encoding: UTF8
  database: reviewit_dev
test:
  adapter: postgresql
  encoding: UTF8
  database: reviewit_test
eos

desc 'Setup reviewit'
task :setup do
  unless File.exist? 'config/database.yml'
    File.open('config/database.yml', 'w') do |file|
      file.write DATABASE_YML
    end
  end

  unless File.exist?('config/reviewit.yml')
    File.open('config/reviewit.yml', 'w') do |file|
      file.write <<eos
# Changing this key will render invalid all existing confirmation,
# reset password and unlock tokens in the database.
secret_key: #{SecureRandom.hex(64)}
# E-mail configuration, for more info see:
# http://edgeguides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
mail:
  sender: foo@bar.com
  host: foo.bar.com
  delivery_method: file
  address:
  port:
  domain:
  authentication:
  user_name:
  password:
  openssl_verify_mode:
  enable_starttls_auto:
  store_location: /tmp/mails
eos
    end
  end

  FileUtils.rm_f 'db/development.sqlite3'
  Rake::Task['db:schema:load'].invoke
  Rake::Task['assets:precompile'].invoke if ENV['RAILS_ENV'] == 'production'
  Rake::Task['build_cli_gem'].invoke
end
