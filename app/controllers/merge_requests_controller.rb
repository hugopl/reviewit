class MergeRequestsController < ApplicationController
  before_action :authenticate_user!

  def update
    ap params
    @patch = merge_request.patches.find_by_id(params[:patch_id]) or raise 'Invalid patch'
    MergeRequest.transaction do
      create_comments params[:comments]
    end

    case params[:mr_action]
    when 'Accept' then accept
    when 'Reject' then reject
    end

    redirect_to action: :show
  end

  def index
    @mrs = project.merge_requests.pending
  end

  def old_ones
    @mrs = project.merge_requests.closed
  end

  def show
    @patch = merge_request.patches.last
    @comments = @patch.comments.order(:location).to_a.inject({}) do |hash, comment|
      location = comment.location.to_i
      if location.zero?
        @patch_comment = comment
      else
        hash[location] ||= []
        hash[location] << comment
      end
      hash
    end

    @mr = merge_request
  end

  private

  def project
    @project ||= current_user.projects.find_by_id(params[:project_id])
  end

  def accept
    @mr.accepted!
  end

  def reject
    @mr.rejected!
  end

  def merge_request
    @project ||= current_user.projects.find_by_id(params[:project_id])
    @mr ||= project.merge_requests.find(params[:id])
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
