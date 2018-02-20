class GitPushWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  PUSH_TYPES = %w(integration ci).freeze

  def perform(patch_id, push_type)
    fail("Wrong push type (#{push_type})") unless PUSH_TYPES.include?(push_type)

    patch = Patch.find(patch_id)
    repository = patch.project.repository
    merge_request = patch.merge_request

    git = Git.new(repository)
    git.clone(merge_request.target_branch) || fail("Failed to clone repository at #{repository}\n#{git.log}")
    if git.am(patch)
      case push_type
      when 'ci' then push_to_ci(git, patch)
      when 'integration' then push_to_integrate(git, merge_request, patch)
      end
    else
      merge_request.needs_rebase!
      merge_request.send_webpush_needs_rebase_notification
    end
  ensure
    git&.cleanup
  end

  private

  def push_to_ci(git, patch)
    branch = patch.ci_branch_name
    # CI pushes are always forced pushes, so we can resubmit to CI.
    push_ok = git.push(branch, forced: true)
    fail("Failed to push branch #{branch}") unless push_ok
    patch.update_attribute(:gitlab_ci_hash, git.sha1)
  end

  def push_to_integrate(git, merge_request, patch)
    push_ok = git.push(merge_request.target_branch)
    if push_ok
      merge_request.status = 'accepted'
      merge_request.send_webpush_accept_notification
    else
      merge_request.add_history_event(reviewer, 'failed to integrate merge request')
      merge_request.status = 'open'
      merge_request.send_webpush_integration_failed
    end
  ensure
    patch.integration_log = git.log
    patch.save!
    merge_request.save!
  end
end
