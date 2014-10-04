require 'trollop'

module Rme
  class App
    attr_reader :api_token
    attr_reader :project_id

    def run
      parse_args
      load_configuration
    rescue
      abort $!.message
    end

  private
    def parse_args
      Trollop::options do
      end
    end

    def load_configuration
      @api_token = git_config 'rme.api_token'
      @project_id = git_config 'rme.project_id'
      raise 'This project seems not configured.' if @api_token.empty? or @project_id.empty?
    end

    def git_config key
      `git config --get #{key} 2>/dev/null`.strip
    end
  end
end
