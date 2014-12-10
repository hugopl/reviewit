class MergeRequestsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :ci_status

  def update
    @patch = merge_request.patches.find_by_id(params[:patch_id]) or raise 'Invalid patch'
    MergeRequest.transaction do
      create_comments params[:comments]
    end

    case params[:mr_action]
    when 'Accept' then accept
    when 'Abandon' then abandon
    else
      redirect_to action: :show
    end
  end

  def index
    @mrs = merge_requests.pending.paginate(page: params[:page])
  end

  def old_ones
    @mrs = merge_requests.closed.paginate(page: params[:page])
  end

  def history
    @mr = project.merge_requests.includes(history_events: [:who]).find(params[:id])
  end

  def show
    @version = version_from_params
    @patch = patch_for(@version)
  end

  def ci_status
    render json: project.ci_status(patch_for(version_from_params)), callback: 'update_ci_status'
  end

  private

  def version_from_params
    version = params[:version].to_i
    raise ActiveRecord::RecordNotFound.new if version < 0
    version = merge_request.patches.count if version.zero?
    version
  end

  def patch_for version
    merge_request.patches[version - 1] or raise ActiveRecord::RecordNotFound.new
  end

  def merge_requests
    project.merge_requests.includes(:author, :patches).order(updated_at: :desc)
  end

  def accept
    @mr.integrate! current_user
    redirect_to action: :index
  end

  def abandon
    @mr.abandon! current_user
    redirect_to action: :index
  end

  def create_comments comments
    return if comments.nil?

    comments.each do |location, text|
      next if text.strip.empty?
      comment = Comment.new
      comment.user = current_user
      comment.patch = @patch
      comment.content = text
      comment.location = location
      comment.save!
    end
  end
end
