class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @code = params[:id]
    render :status => @code
  end
end
