# Clear old CI branches and push the last patch to CI
class RemoveCIBranchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(merge_request_id)
    merge_request = MergeRequest.find(merge_request_id)
    repository = merge_request.project.repository

    possible_ci_branches = merge_request.patches.count.times.map { |i| "mr-#{merge_request.id}-version-#{i + 1}" }
    branches_to_remove = remote_branches(repository) & possible_ci_branches

    git = Git.new(repository)
    git.init
    git.rm_branches(branches_to_remove)
  ensure
    git&.cleanup
  end

  private

  def remote_branches(repository)
    output = `git ls-remote -h #{repository}`
    output.lines.map do |line|
      columns = line.split(/\s/)
      columns[1].gsub('refs/heads/', '')
    end
  end
end
