class ProjectsController < ApplicationController
  def show
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = Project.new
    @project.users << current_user
  end

  def create
    @project = Project.new(project_params)
    set_project_users
    if @project.save
      flash[:success] = 'The project was successfully created.'

      redirect_to @project
    else
      flash.now[:danger] = 'Please, review the form fields below before try again.'

      render 'new'
    end
  end

  def edit
    project
  end

  def update
    params[:project].delete(:jira_password) if (params[:project] || {})[:jira_password].blank?
    project.update_attributes(project_params)
    set_project_users
    if @project.save
      flash[:success] = 'The project was successfully updated.'

      redirect_to @project
    else
      flash.now[:danger] = 'Please, review the form fields below before try again.'

      render :edit
    end
  end

  def destroy
    project.destroy
    flash[:success] = 'The project was successfully destroyed.'

    redirect_to action: :index
  end

  private

  def set_project_users
    names = params[:project][:users].is_a?(Array) ? params[:project][:users] : []
    users = User.where(name: names) << current_user
    users.uniq!
    @project.users = users
  end

  def project_params
    params.require(:project).permit(:name, :repository, :description, :linter,
                                    :gitlab_ci_project_url,
                                    :jira_username, :jira_password, :jira_ticket_regexp,
                                    :jira_api_url)
  end
end
