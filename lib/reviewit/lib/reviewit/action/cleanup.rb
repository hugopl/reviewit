module Reviewit
  class Cleanup < Action
    REMOTE_WARNING = "Using a remote name different than \"origin\"? Tell reviewit:\n" \
                     '  git config --local reviewit.remote my_remote_name'
    def run
      pruned_branches = prune_remote
      return if pruned_branches.empty?

      puts 'Pruning local branches'
      local_branches.each do |branch|
        next unless branch =~ /^(mr-\d+)-.*/
        remove_branch(branch) if pruned_branches.include?($1)
      end
    end

    private

    def remove_branch(branch)
      puts " * [pruned] #{branch}"
      `git branch -D #{branch}`
    end

    def prune_remote
      output = `git remote prune #{remote}`
      abort(REMOTE_WARNING) unless $?.success?

      output.each_line.inject([]) do |memo, line|
        puts line
        memo << $1 if line =~ /#{remote}\/(mr-\d+)-version-\d+$/
        memo
      end
    end

    def local_branches
      top = `git rev-parse --show-toplevel`.strip
      path = "#{top}/.git/refs/heads/"
      Dir["#{path}*"].map do |branch|
        branch.gsub(path, '')
      end
    end

    def remote
      @remote ||= fetch_remote
    end

    def fetch_remote
      remote = `git config --get reviewit.remote 2>/dev/null`.strip
      @custom_remote = !remote.empty?
      @custom_remote ? remote : 'origin'
    end

    def parse_options
      Trollop.options
    end
  end
end
