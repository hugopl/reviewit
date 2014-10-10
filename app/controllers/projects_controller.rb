class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = current_user.projects.find_by_id(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.users << current_user
    if @project.save
      redirect_to @project
    else
      render 'new'
    end
  end

private

  def project_params
    params.require(:project).permit(:name, :repository)
  end
end
