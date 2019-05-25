class ProjectsController < ApplicationController
  def show
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = Project.new
    @project.users << current_user
  end

  def create
    preprocess_user_ids
    @project = Project.new(project_params)
    if @project.save
      flash[:success] = 'The project was successfully created.'

      redirect_to @project
    else
      render 'new'
    end
  end

  def edit
    project
  end

  def update
    params[:project].delete(:jira_password) if (params[:project] || {})[:jira_password].blank?

    if project.update_attributes(project_params)
      flash[:success] = 'The project was successfully updated.'

      path = project.user_ids.include?(current_user.id) ? project : root_path
      redirect_to(path)
    else
      render :edit
    end
  end

  def destroy
    project.destroy
    flash[:success] = 'The project was successfully destroyed.'

    redirect_to action: :index
  end

  private

  def preprocess_user_ids
    user_ids = project_params[:user_ids].split(',').map(&:to_i) << current_user.id
    user_ids.uniq!
    project_params[:user_ids] = user_ids
  end

  def project_params
    data = params.require(:project).permit(:name, :repository, :description, :linter,
                                           :gitlab_ci_project_url, :user_ids,
                                           :jira_username, :jira_password, :jira_ticket_regexp,
                                           :jira_api_url)
    data[:user_ids] = data[:user_ids]&.split(',')&.map(&:to_i)&.compact
    data
  end
end
