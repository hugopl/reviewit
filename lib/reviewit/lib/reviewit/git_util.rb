require 'shellwords'

module Reviewit
  module GitUtil
    def local_branches
      @local_branches ||= read_local_branches
    end

    def remove_branch(branch)
      return if branch.nil?

      puts " * [pruned] #{branch}"
      `git branch -D "#{Shellwords.escape(branch)}"`
    end

    def fetch_repository
      cmd = "git fetch #{remote}"
      puts cmd
      system(cmd)
    end

    def remote
      @remote ||= read_remote_from_config
    end

    def branch_exists?(name)
      `git rev-parse --verify --quiet "#{Shellwords.escape(name)}"`
      $?.success?
    end

    def create_branch(base, name)
      `git checkout --quiet -b "#{Shellwords.escape(name)}" "#{remote}/#{Shellwords.escape(base)}" 2>&1`
      raise "Error creating branch #{name} on top of #{remote}/#{base}" unless $?.success?
    end

    def git_safe_name(name)
      safe_name = name.gsub(/\.\z/, '') # no ending with a dot, not really a git restriction.
      safe_name.gsub!(/^\./, '_') # replace other dots by underscore
      safe_name.gsub!(%r{(\.lock|/)\z}, '_') # git restrictions
      safe_name.gsub!(/[\s\\>:~^\[\]\(\)]/, '_') # more git restrictions
      safe_name.gsub!('-_', '_')
      safe_name.gsub!('_-', '_')
      safe_name.gsub!(/_+/, '_')
      safe_name
    end

    private

    def read_local_branches
      branches = `git branch --no-color --list`.split
      branches.delete('*')
      branches
    end

    def read_remote_from_config
      remote = `git config --get reviewit.remote 2>/dev/null`.strip
      @custom_remote = !remote.empty?
      @custom_remote ? remote : 'origin'
    end
  end
end
