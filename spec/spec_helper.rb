require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'faker'
require 'factory_bot_rails'

RSpec.configure do |config|
  # Use the documentation formatter for detailed output,
  config.default_formatter = 'doc' if config.files_to_run.one?

  Kernel.srand(config.seed)

  include FactoryBot::Syntax::Methods
  Rails.application.config.action_mailer.default_url_options = { host: 'example.com' }
end

# Helper method... here... waiting friends to live in its own file
def patch(patch)
  File.read("spec/fixtures/#{patch}.patch")
end
