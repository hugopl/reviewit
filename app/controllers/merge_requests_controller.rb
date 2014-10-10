class MergeRequestsController < ApplicationController
  before_action :authenticate_user!

  def update
    @patch = merge_request.patches.find_by_id(params[:patch_id]) or raise 'Invalid patch'
    MergeRequest.transaction do
      create_comments params[:comments]
    end
    render text: (ap params)
  end

  def index
    @project = current_user.projects.find_by_id(params[:project_id])
  end

  def show
    @patch = merge_request.patches.last
    @mr = merge_request
  end

  private

  def merge_request
    @project ||= current_user.projects.find_by_id(params[:project_id]) or raise 'Invalid project.'
    project.merge_requests.find(params[:id]) or raise 'Merge request not found.'
  end

  def create_comments comments
    comments.each do |location, text|
      comment = Comment.new
      comment.user = current_user
      comment.patch = @patch
      comment.content = text
      comment.location = location
      comment.save!
    end
  end
end
