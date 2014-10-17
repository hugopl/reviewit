class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = current_user.projects.find_by_id(params[:id])
  end

  def new
    @project = Project.new
    @project.users << current_user
  end

  def create
    @project = Project.new(project_params)
    names = params[:project][:users].is_a?(Array) ? params[:project][:users] : []
    users = User.where(name: names) << current_user
    users.uniq!

    @project.users = users
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
