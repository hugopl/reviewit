class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render file: "#{Rails.root}/public/404", layout: false, status: :not_found
  end

  layout Proc.new { |_controller|
    user_signed_in? ? 'application' : 'devise/sessions'
  }

  def project
    @project ||= current_user.projects.find(params.include?(:project_id) ? params[:project_id] : params[:id])
  end

  def merge_request
    @mr ||= project.merge_requests.find(params.include?(:merge_request_id) ? params[:merge_request_id] : params[:id])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end
end
