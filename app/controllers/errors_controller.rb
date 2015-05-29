class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @code = params[:id]
  end
end
