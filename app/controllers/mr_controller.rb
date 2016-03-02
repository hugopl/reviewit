class MrController < ApplicationController
  before_action :authenticate_user!

  def show
    project = current_user.projects.joins(:merge_requests).where('merge_requests.id = ?', params[:id])
    redirect_to("/projects/#{project.id}/merge_requests/#{params[:id]}")
  end
end
