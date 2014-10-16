class MrController < ApplicationController
  before_action :authenticate_user!

  def show
    project = MergeRequest.find(params[:id]).project
    if project.users.include? current_user
      redirect_to "/projects/#{project.id}/merge_requests/#{params[:id]}"
    else
      raise ActiveRecord::RecordNotFound.new
    end
  end
end
