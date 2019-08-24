module Reviewit
  class CI < Grape::API
    # We should protect this route somehow in the future.
    post :ci_update do
      data = JSON.parse(request.body.read)
      sha = data['sha']
      build = data['build_id']
      status = data['build_status']

      raise 'Invalid parameters.' if sha.nil? || build.nil? || status.nil?

      status = Patch.gitlab_ci_statuses[status].to_i
      patch = Patch.find_by(gitlab_ci_hash: sha)
      patch.update_attributes(gitlab_ci_status: status, gitlab_ci_build: build)

      if patch.failed? || patch.success?
        title = patch.success? ? 'CI green!!' : 'CI failed :-('
        patch.author.send_webpush_assync(title, patch.subject, patch.merge_request.my_path)
      end
    rescue StandardError => e
      raise e.message
    end
  end
end
