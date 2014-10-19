module Api
  class MergeRequestsController < ApiController

    def index
      render json: project.merge_requests.pending
    end

    def show
      patch = merge_request.patches.newer
      raise 'No patches were found for this merge request.' unless patch.is_a? Patch

      render json: {
        id: @mr.id,
        target_branch:  @mr.target_branch,
        status:         @mr.status,
        author:         @mr.owner.name,
        author_email:   @mr.owner.email,
        commit_message: @mr.commit_message,
        diff:           patch.diff
      }
    end

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

        render json: {}
      end
    end
  end
end
