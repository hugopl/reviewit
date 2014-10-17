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
    set_project_users
    if @project.save
      redirect_to @project
    else
      render 'new'
    end
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def update
    @project = current_user.projects.find(params[:id])
    @project.update_attributes(project_params)
    set_project_users
    if @project.save
      redirect_to @project
    else
      render 'new'
    end
  end

private

  def set_project_users
    names = params[:project][:users].is_a?(Array) ? params[:project][:users] : []
    users = User.where(name: names) << current_user
    users.uniq!
    @project.users = users
  end

  def project_params
    params.require(:project).permit(:name, :repository)
  end
end
