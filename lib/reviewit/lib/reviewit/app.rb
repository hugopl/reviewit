require 'trollop'

require 'reviewit/api.rb'
require 'reviewit/action/action.rb'
require 'reviewit/version.rb'

module Reviewit
  ACTIONS = %w(push list show apply accept cancel cleanup open lock unlock config).freeze
  ACTIONS.each do |action|
    autoload action.capitalize.to_sym, "reviewit/action/#{action}.rb"
  end

  class App
    attr_reader :linter
    attr_reader :action_name

    def run
      return show_help if ARGV == ['--help']
      return show_version if ARGV == ['--version']

      # Due to a bad decision in the past this entire gem modifies the ARGV
      # This should be fixed later... some day.
      cached_argv ||= ARGV.dup

      no_retry = ARGV.first == '--no-retry'
      ARGV.shift if no_retry

      load_configuration
      api = Api.new(@base_url, @project_id, @api_token, @project_hash)

      action = action_class.new(self, api)
      action.run
    rescue RetryExpected
      if no_retry
        abort('Something bad happened.')
      else
        exec("#{$PROGRAM_NAME} --no-retry #{cached_argv.join(' ')}")
      end
    rescue RuntimeError, Errno::ECONNREFUSED
      abort $!.message
    rescue Interrupt
      abort "\nInterruped! Bye!"
    end

    def git_config(key)
      `git config --get #{key} 2>/dev/null`.strip
    end

    private

    def action_class
      show_help(:abort) if ARGV.empty?

      @action_name = ARGV.shift
      raise 'Unknown action' unless ACTIONS.include?(@action_name)

      Reviewit.const_get(@action_name.capitalize)
    end

    def show_help(should_abort = nil)
      help = <<eot
review actions:
  push      Create or update a review.
  list      List pending reviews.
  accept    Accept a merge request
  cancel    Cancel current review.
  cleanup   Prune remote branches and their respective local branches.
  apply     Apply one or more patches from merge requests on your tree.
  show      Show patch from a merge request.
  open      Open a merge request in your default browser.
  lock      Lock a branch, so no MRs will be accepted there.
  unlock    Unlock a branch.
  config    Set default options for any review CLI action.

To get help on subcommands use for example:
  review push --help
eot
      puts help
      abort if should_abort
    end

    def show_version
      puts "Review It v#{Reviewit::VERSION}"
    end

    def load_configuration
      @api_token = git_config 'reviewit.apitoken'
      @project_id = git_config 'reviewit.projectid'
      @base_url = git_config 'reviewit.baseurl'
      @linter = git_config 'reviewit.linter'
      @project_hash = git_config('reviewit.projecthash')
      raise 'This project seems not configured.' if @api_token.empty? or @project_id.empty? or @base_url.empty?
    end
  end
end
