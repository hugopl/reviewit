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
    end

    def update
      mr = merge_request
      raise "You can not update a #{mr.status} merge request." if mr.closed?

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
    end
  end
end
