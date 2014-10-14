module Api
  class MergeRequestsController < ApiController
    def create

      MergeRequest.transaction do
        mr = MergeRequest.new
        mr.project = project
        mr.owner = current_user
        mr.subject = params[:subject]
        mr.commit_message = params[:commit_message]
        mr.target_branch = params[:target_branch]

        mr.save!

        patch = Patch.new
        patch.merge_request = mr
        patch.diff = params[:diff]
        patch.save!
        render(json: { :mr_id => mr.id })
      end
    rescue ActiveRecord::ActiveRecordError
      render( json: { :error => "Could not create the merge request.\n#{$!.message}" }, status: :bad_request)
    end

    def update
      mr = merge_request
      MergeRequest.transaction do
        mr.subject = params[:subject]
        mr.commit_message = params[:commit_message]
        mr.save!

        patch = Patch.new
        patch.merge_request = mr
        patch.diff = params[:diff]
        patch.save!

        unless params[:comments].empty?
          comment = Comment.new
          comment.patch = patch
          comment.user = current_user
          comment.content = params[:comments]
          comment.save!
        end

        render json: ''
      end
    rescue ActiveRecord::ActiveRecordError
      render( json: { :error => "Could not update the merge request.\n#{$!.message}" }, status: :bad_request)
    rescue RuntimeError
      render text: $!.message, status: :not_found
    end

  private

    def merge_request
      @project ||= current_user.projects.find(params[:project_id])
      project.merge_requests.find(params[:id])
    end
  end
end
