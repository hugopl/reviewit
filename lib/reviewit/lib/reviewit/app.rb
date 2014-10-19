require 'trollop'
require 'awesome_print'

require 'reviewit/api.rb'
require 'reviewit/action/action.rb'
require 'reviewit/version.rb'

module Reviewit

  ACTIONS = %w(push pending show).freeze
  ACTIONS.each do |action|
    autoload action.capitalize.to_sym, "reviewit/action/#{action}.rb"
  end

  class App
    attr_reader :api_token
    attr_reader :project_id

    def run
      load_configuration
      api = Api.new(@base_url, @project_id, @api_token)

      action = action_class.new(api)
      action.run
    rescue RuntimeError
      abort $!.message
    end

  private
    def action_class
      show_help('') if ARGV.empty?

      action_name = ARGV.shift
      raise 'Unknown action' unless ACTIONS.include? action_name

      Reviewit.const_get(action_name.capitalize)
    end

    def show_help should_abort
      help = <<eot
review actions:
  push      Create or update a review.
  cancel    Cancel current review.
  pending   Show pending reviews.
  apply     Apply patch from a merge request on your tree.
  show      Show patch from a merge request.
eot
      puts help
      abort(should_abort) if should_abort
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
