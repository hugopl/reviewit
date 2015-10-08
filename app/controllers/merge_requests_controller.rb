class MergeRequestsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :ci_status

  def update
    @patch = merge_request.patches.find_by_id(params[:patch_id]) or raise 'Invalid patch'
    merge_request.add_comments(current_user, @patch, params[:comments])

    MergeRequestMailer.updated(current_user, merge_request, params).deliver
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
    @from = params[:from].to_i
    @to = params[:to].to_i
    @to = merge_request.patches.count if @to.zero?
    @diff = Diff.new(merge_request.patch_diff(@from, @to))

    if @from.zero?
      @patch = merge_request.patches[@to - 1]
      @comments = @patch.comments.group_by(&:location)
    else
      @patch = merge_request.patch
      @comments = []
      @disable_comments = true
    end
  end

  def ci_status
    render json: project.ci_status(patch_for(version_from_params))
  end

  private

  def version_from_params
    version = params[:version].to_i
    raise ActiveRecord::RecordNotFound, 'Patch not found' if version < 0
    version = merge_request.patches.count if version.zero?
    version
  end

  def patch_for(version)
    merge_request.patches[version - 1] or raise ActiveRecord::RecordNotFound.new, 'Patch not found'
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
end
