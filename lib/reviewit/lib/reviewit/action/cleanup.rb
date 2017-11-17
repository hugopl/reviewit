module Reviewit
  class Cleanup < Action
    REMOTE_WARNING = "Using a remote name different than \"origin\"? Tell reviewit:\n" \
                     '  git config --local reviewit.remote my_remote_name'
    def run
      thread = Thread.new do
        @active_mrs = api.pending_merge_requests.map { |mr| mr[:id].to_i }
      end
      puts 'Looking for outdated remote branches...'
      system("git remote prune #{remote}")
      thread.join

      puts 'Looking for outdated local branches...'
      outdated_branches = local_branches_ids - @active_mrs
      outdated_branches.each do |mr_id|
        remove_branch(branch_name(mr_id))
      end
    end

    private

    include GitUtil

    def branch_name(mr_id)
      local_branches.find { |branch| branch.start_with?("mr-#{mr_id}-") }
    end

    def local_branches_ids
      local_branches.map do |branch|
        $1.to_i if branch =~ /^mr-(\d+)-.*/
      end.compact
    end
  end
end
