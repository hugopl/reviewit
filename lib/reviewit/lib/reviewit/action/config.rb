require 'json'

module Reviewit
  class Config < Action
    def run
      params = Shellwords.escape(options[:params].to_json)
      `git config --local reviewit.config#{options[:action]} #{params}`
      abort('Error setting configuration.') unless $?.success?
      puts 'Configuration set!'
    end

    def self.parse_options
      subcommands = Reviewit::ACTIONS - ['cancel']
      options = Optimist.options do
        banner "Use review config <action> <parameter1> <parameter2> ...\n\nOptions:"
        stop_on subcommands
      end
      options[:action] = ARGV.shift
      options[:params] = ARGV.dup

      # This is used just to parse the action options and get rid of errors or unknown options.
      Reviewit.const_get(options[:action].capitalize).parse_options

      options
    end
  end
end
