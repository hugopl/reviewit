module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_user_by_token!
    before_action :authenticate_user!, only: []

  protected

    def authenticate_user_by_token!
      @current_user = User.find_by_api_token(params[:api_token]) or raise 'Sorry, invalid token.'

      project_id = params[:controller] == 'api/projects' ? params[:id] : params[:project_id]
      @project = current_user.projects.find_by_id(project_id) or raise 'Invalid project.'
    rescue RuntimeError
      render text: $!.message, status: :unauthorized
    end
  end
end
