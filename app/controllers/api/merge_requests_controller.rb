module Api
  class MergeRequestsController < ApiController

    def index
      render json: project.merge_requests.pending
    end

    def show
      patch = merge_request.patch
      raise 'No patches were found for this merge request.' unless patch.is_a? Patch

      render json: {
        id: @mr.id,
        target_branch:  @mr.target_branch,
        status:         @mr.status,
        author:         @mr.author.name,
        author_email:   @mr.author.email,
        commit_message: @mr.commit_message,
        diff:           patch.diff
      }
    end

    def destroy
      raise 'You can not abandon a merge request in the integration process, wait a bit.' if merge_request.integrating?
      raise 'Too late, this merge request was already accepted.' if merge_request.accepted?
      raise 'This merge request was already abandoned.' if merge_request.abandoned?
      merge_request.abandon! current_user
      render json: {}
    end

    def show_git_patch
      render json: { patch: merge_request.git_format_patch }
    end

    def create
      MergeRequest.transaction do
        mr = MergeRequest.new
        mr.project = project
        mr.author = current_user
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
