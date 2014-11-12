require Rails.root.join('lib', 'reviewit', 'lib', 'reviewit', 'version.rb')

module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :check_cli_version!
    before_action :authenticate_user_by_token!
    before_action :authenticate_user!, only: []

    rescue_from RuntimeError do |exception|
      render json: { error: exception.message }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: 'Can not find the merge request, project or whatever you tried to find/use.' }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      render json: { error: 'Problem found: #{exception.message}' }, status: :bad_request
    end

  protected

    def check_cli_version!
      cli_version = request.headers['X-CliVersion']
      return if cli_version == Reviewit::VERSION
      message = "You need Review it! version #{Reviewit::VERSION}, but have #{cli_version}."
      render json: { error: message }, status: :upgrade_required
    end

    def authenticate_user_by_token!
      api_token = request.headers['X-ApiToken']
      @current_user = User.find_by_api_token(api_token) or raise 'Sorry, invalid token.'


      project_id = params[:controller] == 'api/projects' ? params[:id] : params[:project_id]
      @project = current_user.projects.find(project_id)
    rescue RuntimeError
      render json: { error: $!.message }, status: :unauthorized
    end
  end
end
