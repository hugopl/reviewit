class MergeRequestsController < ApplicationController
  def update
    @patch = merge_request.patches.find_by(id: params[:patch_id]) or raise 'Invalid patch'
    @mr.solve_issues_by_location(current_user, @patch, params[:solved].keys) if params[:solved].present?
    @mr.add_comments(current_user, @patch, params[:comments], params[:blockers])

    MergeRequestMailer.updated(current_user, merge_request, params).deliver
    redir_params = { action: :show }
    redir_params[:to] = params[:to] if params[:to]

    case params[:mr_action]
    when 'accept' then accept
    when 'abandon' then abandon
    else
      @mr.likes.create(user: current_user) if params[:mr_action] == 'like'
      redirect_to(redir_params)
    end
  rescue RuntimeError => e
    flash[:danger] = e.message
    redirect_to(redir_params)
  end

  def solve_issues
    merge_request.solve_issues_by_id(current_user, params[:solved])
    n = params[:solved].count
    flash[:success] = "#{n} #{'issue'.pluralize(n)} tagged as solved!"
  rescue RuntimeError => e
    flash[:danger] = e.message
  ensure
    redirect_to action: :show
  end

  def index
    # There's no pagination on pending MRs, since this page is supposed to be always with a low number of MRs
    mrs = merge_requests.pending.to_a
    @total_mrs = mrs.count
    @waiting_others = MergeRequest.waiting_others(mrs, current_user)
    @waiting_you = mrs - @waiting_others
  end

  def old_ones
    @mrs = merge_requests.closed.paginate(page: params[:page])
    @target_branch = params[:target_branch]
    @author = params[:author]
    @reviewer = params[:reviewer]
    @subject = params[:subject]
    @mrs = @mrs.where(target_branch: @target_branch) if @target_branch.present?
    @mrs = @mrs.where(author: @author) if @author.present?
    @mrs = @mrs.where(reviewer: @reviewer) if @reviewer.present?
    @mrs = @mrs.where('lower(subject) LIKE ?', "%#{@subject.downcase}%") if @subject.present?
    @total = @mrs.count
  end

  def history
    @mr = project.merge_requests.includes(history_events: [:who]).find(params[:id])
  end

  def show
    @from = params[:from].to_i
    @to = params[:to].to_i
    @to = merge_request.patches.count if @to.zero?
    @diff = merge_request.patch_diff(@from, @to)

    if @from.zero?
      @patch = merge_request.patches[@to - 1]
      @comments = @patch.comments.group_by(&:location)
    else
      @patch = merge_request.patch
      @comments = []
      @disable_comments = true
    end
  end

  def trigger_ci
    @patch = merge_request.patch
    if @patch.ok_to_retry_ci?
      @patch.push_to_ci
      flash[:success] = 'CI triggered!'
    else
      flash[:info] = 'You can not trigger CI for this patch yet.'
    end
    redirect_to(action: :show)
  end

  private

  def version_from_params
    version = params[:version].to_i
    raise ActiveRecord::RecordNotFound, 'Patch not found' if version.negative?

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
    @mr.integrate!(current_user, @patch.id)
    redirect_to action: :index
  rescue RuntimeError => e
    flash[:danger] = e.message
    redirect_to action: :show
  end

  def abandon
    @mr.abandon! current_user
    redirect_to action: :index
  end
end
