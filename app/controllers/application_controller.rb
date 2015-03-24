class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

  layout proc { |_controller|
    user_signed_in? ? 'application' : 'devise/sessions'
  }

  def project
    @project ||= current_user.projects.find(widget_id(:project_id))
  end

  def merge_request
    @mr ||= project.merge_requests.find(widget_id(:merge_request_id))
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  private

  def widget_id(widget)
    params.include?(widget) ? params[widget] : params[:id]
  end
end
