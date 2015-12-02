module Reviewit
  class CI < Grape::API
    # We should protect this route somehow in the future.
    post :ci_update do
      begin
        data = JSON.parse(request.body.read)
        sha = data['sha']
        build = data['build_id']
        status = data['build_status']

        raise 'Invalid parameters.' if sha.nil? || build.nil? || status.nil?

        status = Patch.gitlab_ci_statuses[status].to_i
        Patch.where(gitlab_ci_hash: sha).update_all(gitlab_ci_status: status, gitlab_ci_build: build)
      rescue => e
        raise e.message
      end
    end
  end
end
