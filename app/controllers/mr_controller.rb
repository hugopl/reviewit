class MrController < ApplicationController
  def show
    project = current_user.projects.joins(:merge_requests).where('merge_requests.id = ?', params[:id]).first
    raise ActiveRecord::RecordNotFound, 'Merge request not found.' if project.nil?
    redirect_to("/projects/#{project.id}/merge_requests/#{params[:id]}")
  end
end
