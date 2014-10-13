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
      # TODO put this in a transaction
      mr = merge_request

      mr.subject = params[:subject]
      mr.commit_message = params[:commit_message]
      mr.save!

      # TODO avoid this code repetition
      patch = Patch.new
      patch.merge_request = mr
      patch.diff = params[:diff]
      patch.save!

      comment = Comment.new
      comment.patch = patch
      comment.user = current_user
      comment.content = params[:comments]
      comment.save!

      render json: ''
    rescue RuntimeError
      render text: $!.message, status: :not_found
    end

  private

    def merge_request
      @project ||= current_user.projects.find_by_id(params[:project_id]) or raise 'Invalid project.'
      project.merge_requests.find(params[:id]) or raise 'Merge request not found.'
    end
  end
end
