require 'trollop'
require 'awesome_print'

require 'reviewit/api.rb'
require 'reviewit/action/action.rb'
require 'reviewit/version.rb'

module Reviewit

  ACTIONS = %w(push abort list).freeze
  ACTIONS.each do |action|
    autoload action.capitalize.to_sym, "r-me/action/#{action}.rb"
  end

  class App
    attr_reader :api_token
    attr_reader :project_id

    def run
      load_configuration
      options = parse_args

      api = Api.new(@base_url, @project_id, @api_token)
      action = Rme.const_get(options[:action].capitalize).new(api, options)
      action.run
    rescue RuntimeError
      abort $!.message
    end

  private
    def parse_args
      options = Trollop::options do
        opt :message, 'A message to the given action', type: String
      end

      action = ARGV.empty? ? 'push' : ARGV.first
      raise 'Unknown action' unless ACTIONS.include? action

      options[:action] = action
      options
    end

    def load_configuration
      @api_token = git_config 'rme.apitoken'
      @project_id = git_config 'rme.projectid'
      @base_url = git_config 'rme.baseurl'
      raise 'This project seems not configured.' if @api_token.empty? or @project_id.empty? or @base_url.empty?
    end

    def git_config key
      `git config --get #{key} 2>/dev/null`.strip
    end
  end
end
