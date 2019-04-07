class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :time_zone, if: :current_user

  layout proc { |_controller|
    user_signed_in? ? 'application' : 'devise'
  }

  def project
    @project ||= current_user.projects.find(widget_id(:project_id))
  end

  def merge_request
    @mr ||= project.merge_requests.find(widget_id(:merge_request_id))
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  private

  def widget_id(widget)
    params.include?(widget) ? params[widget] : params[:id]
  end
end
